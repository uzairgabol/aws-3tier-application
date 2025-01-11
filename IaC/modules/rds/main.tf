resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-sngp"
  subnet_ids = var.private_subnet_db

  tags = {
    Name = "DB-SNGP"
  }
}

resource "aws_db_instance" "database" {
  identifier           = "database-1"
  engine              = "mysql"
  engine_version      = "8.0.35"
  instance_class      = "db.t4g.micro"
  allocated_storage   = 5
  storage_type        = "gp2"
  username            = "admin"
  password            = "test1234"
  skip_final_snapshot = true

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.rds_sg_id]

  backup_retention_period = 0
  multi_az               = false
}