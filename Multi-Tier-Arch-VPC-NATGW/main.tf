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
    Name = "private-subnet"
  }
}

resource "aws_subnet" "priv2sub" {
  cidr_block = "10.0.30.0/24"
  vpc_id = aws_vpc.myvpc.id
  assign_ipv6_address_on_creation = false
  availability_zone = "ap-south-1c"
  depends_on = [aws_subnet.privsub]
  tags = {
    Name = "private-subnet2"
  }
}
resource "aws_internet_gateway" "myigw" {
  depends_on = [aws_subnet.priv2sub]
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "my-internet-gateway"
  }
}

resource "aws_route_table" "mypubroute" {
  vpc_id = aws_vpc.myvpc.id
  depends_on = [aws_internet_gateway.myigw]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.myigw.id}"
  }
}

resource "aws_route_table_association" "mypubrouteassociation" {
  depends_on = [aws_route_table.mypubroute]
  subnet_id = "${aws_subnet.pubsub.id}"
  route_table_id = "${aws_route_table.mypubroute.id}"
}

resource "aws_eip" "nateip" {
  vpc = true
  depends_on = [aws_route_table_association.mypubrouteassociation]
}
resource "aws_nat_gateway" "mynatgw" {
  allocation_id = aws_eip.nateip.id
  subnet_id = aws_subnet.pubsub.id
  depends_on = [aws_eip.nateip]
}

resource "aws_route_table" "myprivroute" {
  vpc_id = aws_vpc.myvpc.id
  depends_on = [aws_nat_gateway.mynatgw]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.mynatgw.id}"
  }
}

resource "aws_route_table_association" "myprivrouteassociation" {
  route_table_id = "${aws_route_table.myprivroute.id}"
  depends_on = [aws_route_table.myprivroute]
  subnet_id = "${aws_subnet.privsub.id}"
}

resource "aws_route_table_association" "myprivrtassociation" {
  route_table_id = "${aws_route_table.myprivroute.id}"
  depends_on = [aws_route_table_association.myprivrouteassociation]
  subnet_id = "${aws_subnet.priv2sub.id}"
}

resource "null_resource" "mykey" {
  depends_on = [aws_route_table_association.myprivrtassociation]
  provisioner "local-exec" {
    command = "aws ec2 create-key-pair --key-name ec2key --query 'KeyMaterial' --output text > mykeypair.pem"
  }
}

resource "aws_security_group" "sg1" {
  name        = "ssh,http"
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

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.myvpc.id
  depends_on = [aws_security_group.sg1]
  ingress {
    protocol  = "tcp"
    self      = true
    from_port = 3306
    to_port   = 3306
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wordpressins" {
  ami = "ami-0bcf5425cdc1d8a85"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  availability_zone = "ap-south-1a"
  depends_on = [aws_default_security_group.default]
  key_name = "ec2key"
  subnet_id = "${aws_subnet.pubsub.id}"
  vpc_security_group_ids = [aws_security_group.sg1.id]
  tags = {
    Name = "wordpress"
  }
}

resource "aws_db_subnet_group" "private" {
  name       = "privatedbsubgroup"
  subnet_ids = [aws_subnet.privsub.id, aws_subnet.priv2sub.id]
  depends_on = [aws_instance.wordpressins]

  tags = {
    Name = "My Private DB subnet group"
  }
}

resource "aws_db_instance" "wordpressdb" {
  depends_on = [aws_db_subnet_group.private]
  instance_class = "db.t2.micro"
  allocated_storage = 10
  availability_zone = "ap-south-1b"
  engine = "mysql"
  engine_version = "5.7"
  name = "mydb"
  username = "admin"
  password = "redhat111{"
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.private.name
  port = 3306
}

resource "null_resource" "null_local1" {
  depends_on = [aws_db_instance.wordpressdb]
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("./mykeypair.pem")
    host = aws_instance.wordpressins.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install git -y",
      "sudo mkdir /github",
      "sudo git clone  https://github.com/AWS-Cloud-Community-LPU/Scripts-For-Webinar.git /github/" ,
      "sudo chmod +x /github/AWS-Engage/Wordpress.py",
      "sudo python /github/AWS-Engage/Wordpress.py",
      "sudo cp -rf /home/ec2-user/wordpress /var/www/html/",
      "sudo systemctl restart httpd"
    ]
  }
}