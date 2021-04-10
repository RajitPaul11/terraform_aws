output "instance_public_ip" {
  value = aws_instance.myins[0].public_ip
}