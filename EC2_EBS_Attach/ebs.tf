resource "aws_ebs_volume" "ebsvol" {
  availability_zone = "ap-south-1a"
  depends_on = [aws_instance.ec2ins]
  size = 5
  tags = {
    "Name" = "PenDrive"
  }
}

