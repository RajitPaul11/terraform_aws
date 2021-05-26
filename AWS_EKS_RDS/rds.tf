resource "aws_default_security_group" "default" {
  vpc_id = "vpc-5bedf033"
  depends_on = [aws_eks_node_group.eks_ng]
  ingress {
    protocol  = "tcp"
    self      = true
    from_port = 3306
    to_port   = 3306
    cidr_blocks = ["172.31.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "private" {
  name       = "privatedbsubgroup"
  subnet_ids = ["subnet-028858bf29b10e55a","subnet-0eb21f501fbf62ca2"]
  depends_on = [aws_default_security_group.default]

  tags = {
    Name = "My Private DB subnet group"
  }
}
resource "aws_db_instance" "wordpressdb" {
  depends_on = [aws_db_subnet_group.private]
  instance_class = "db.t2.micro"
  allocated_storage = 10
  availability_zone = "ap-south-1b"
  engine = "mysql"
  engine_version = "5.7"
  name = "mydb"
  username = "admin"
  password = "redhat111{"
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.private.name
  port = 3306
}
