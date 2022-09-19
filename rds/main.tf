variable "vpc_id" {}
variable "inbound_security_groups" {}
variable "subnet_ids" {}

resource "random_string" "rdsuser" {
  length           = 16
  special          = false
}

resource "random_password" "rdspassword" {
  length           = 32
  special          = false
}

resource "aws_security_group" "allow_frontend_to_db" {
  name        = "rds-demo-allow-frontend-to-db"
  description = "Allow server traffic to DB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Frontend to DB"
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    security_groups = var.inbound_security_groups
  }

}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds"
  subnet_ids = var.subnet_ids
}

  resource "aws_db_instance" "mysql-db" {
  allocated_storage    = 10
  db_name              = "db"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = random_string.rdsuser.result
  password             = random_password.rdspassword.result
  parameter_group_name = "default.mysql5.7"
  iam_database_authentication_enabled = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.allow_frontend_to_db.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
}