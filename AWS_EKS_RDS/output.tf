output "rolearn" {
  value = aws_iam_role.ngrole.arn
}

output "rds_endpoint" {
  value = aws_db_instance.wordpressdb.endpoint
}