output "mypubsubnetname" {
  value = aws_subnet.mypubsubnet
}

output "myprivsubnetname" {
  value = aws_subnet.myprivsubnet
}

output "myec2dnsname" {
  value = aws_instance.myec2.public_dns
}