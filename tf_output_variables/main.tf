resource "aws_instance" "awsec2" {
  ami = "ami-02a45d709a415958a"
  availability_zone = "ap-south-1a"
  count = 1
  key_name = " DevopsDiscussion"
  instance_type = "t2.micro"
}

output "pub_ip" {
  value = aws_instance.awsec2.public_ip
  description = "Print public IPv4"
}