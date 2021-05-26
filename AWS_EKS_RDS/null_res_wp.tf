resource "null_resource" "null1" {
  depends_on = [aws_db_instance.wordpressdb]
  provisioner "local-exec" {
    command = "kubectl apply -f wordpress-deployment.yaml"
  }
}