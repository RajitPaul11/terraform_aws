resource "aws_db_subnet_group" "public" {
  name = "publicsubnetgroup"
  subnet_ids = ["subnet-8c1972c0", "subnet-4ff24f34", "subnet-01fcc669"]

  tags = {
    Name = "My Public Subnet Group"
  }
}

resource "aws_db_instance" "testrdsdb" {
  instance_class = "db.t3.large"
  allocated_storage = 10
  availability_zone = "ap-south-1a"
  db_subnet_group_name = aws_db_subnet_group.public.name
  engine = "postgres"
  engine_version = 13.4
  name = "mydb"
  username = "dbadmin"
  password = "helloworld"
  port = 3306
  skip_final_snapshot = true
}