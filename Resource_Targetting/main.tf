resource "random_string" "server-prefix" {
  length = 6
  upper = false
  special = false
}

resource "aws_instance" "web" {
  ami = "ami-041db4a969fe3eb68"
  instance_type = "t2.micro"
  tags = {
    Name = "${random_string.server-prefix.id}-web"
  }
}