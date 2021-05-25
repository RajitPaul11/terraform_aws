resource "aws_security_group" "sg1" {
  depends_on = [null_resource.mykey]

  name        = "ec2_sg"
  description = "Security Group for EC2"
  vpc_id      = "vpc-5bedf033"

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG for EC2"
  }
}