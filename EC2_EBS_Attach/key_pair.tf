resource "null_resource" "mykey" {
  provisioner "local-exec" {
    command = "aws ec2 create-key-pair --key-name ec2inskey --query 'KeyMaterial' --output text > mykeypair.pem"
  }
}