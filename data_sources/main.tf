data "aws_key_pair" "ec2-key" {
  key_name = "test-key-pair"
}

resource "aws_instance" "ec2-instance" {
  key_name = data.aws_key_pair.ec2-key.key_name
  instance_type = "t2.micro"
  ami = "ami-041db4a969fe3eb68"
}