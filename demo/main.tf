resource "aws_vpc" "myvpc" {
  cidr_block = var.myvpccidrblock
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_subnet" "mypubsubnet" {
  cidr_block = var.mypubsubnetcidr
  vpc_id     = aws_vpc.myvpc.id
  availability_zone = var.pubaz
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "myprivsubnet" {
  cidr_block = var.myprivsubnetcidr
  vpc_id     = aws_vpc.myvpc.id
  availability_zone = var.privaz
  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_nat_gateway" "mynatgw" {
  subnet_id = aws_subnet.mypubsubnet.id
}

resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = aws_subnet.mypubsubnet.cidr_block
    gateway_id = aws_internet_gateway.myigw.id
  }
}

resource "aws_route_table" "privrt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = aws_subnet.myprivsubnet.cidr_block
    gateway_id = aws_nat_gateway.mynatgw.id
  }
}

resource "aws_key_pair" "mykeypair" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
  key_name = var.mykey
}
resource "aws_instance" "myec2" {
  ami = var.amiid
  instance_type = var.myinsttype
  key_name = aws_key_pair.mykeypair
  subnet_id = aws_subnet.mypubsubnet.id
}
