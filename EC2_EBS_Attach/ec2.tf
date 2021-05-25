resource "aws_instance" "ec2ins" {
  ami = "ami-010aff33ed5991201"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  availability_zone = "ap-south-1a"
  depends_on = [aws_security_group.sg1]
  key_name = "ec2inskey"
  vpc_security_group_ids = [aws_security_group.sg1.id]
  tags = {
    "Name" = "EC2Instance"
  }
}