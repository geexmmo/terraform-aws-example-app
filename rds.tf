resource "aws_db_subnet_group" "cloudx" {
  name       = "ghost"
  subnet_ids = [for s in data.aws_subnet.cloudx-private : s.id]

  tags = {
    Name = "ghost database subnet group"
  }
}

resource "aws_db_instance" "cloudx" {
  db_name                = "ghost"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  storage_type           = "gp2"
  vpc_security_group_ids = [aws_security_group.mysql.id]
  db_subnet_group_name   = aws_db_subnet_group.cloudx.id
  skip_final_snapshot    = true
  username               = var.aws_rds_username
  password               = var.aws_rds_password
  identifier             = "ghost"
  tags = {
    "Name" = "cloudx"
  }
}
# output "rds" {
#   value = aws_db_instance.cloudx.identifier
# }