provider "aws" {
  region = "ap-south-1"
}
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "pubsub" {
  cidr_block = "10.0.10.0/24"
  vpc_id = aws_vpc.myvpc.id
  assign_ipv6_address_on_creation = false
  availability_zone = "ap-south-1a"
  depends_on = [aws_vpc.myvpc]
  tags = {
    Name = "Public-Subnet"
  }
}

resource "aws_subnet" "privsub" {
  cidr_block = "10.0.20.0/24"
  vpc_id = aws_vpc.myvpc.id
  assign_ipv6_address_on_creation = false
  availability_zone = "ap-south-1b"
  depends_on = [aws_subnet.pubsub]
  tags = {
    Name = "Private-Subnet"
  }
}

resource "aws_internet_gateway" "myigw" {
  depends_on = [aws_subnet.privsub]
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "my-internet-gateway"
  }
}

resource "aws_route_table" "myroute" {
  vpc_id = aws_vpc.myvpc.id
  depends_on = [aws_internet_gateway.myigw]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.myigw.id}"
  }
}

resource "aws_route_table_association" "myrouteassociation" {
  depends_on = [aws_route_table.myroute]
  subnet_id = "${aws_subnet.pubsub.id}"
  route_table_id = "${aws_route_table.myroute.id}"
}

resource "null_resource" "mykey" {
  depends_on = [aws_route_table_association.myrouteassociation]
  provisioner "local-exec" {
    command = "aws ec2 create-key-pair --key-name ec2key --query 'KeyMaterial' --output text > mykeypair.pem"
  }
}

resource "aws_security_group" "sg1" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  depends_on = [null_resource.mykey]

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh,http"
  }
}

resource "aws_instance" "wordpressins" {
  ami = "ami-0d19284667fb9aca0"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  availability_zone = "ap-south-1a"
  depends_on = [aws_security_group.sg1]
  key_name = "ec2key"
  subnet_id = "${aws_subnet.pubsub.id}"
  security_groups = [aws_security_group.sg1.id]
}

