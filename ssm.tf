resource "aws_ssm_parameter" "dbpassw" {
  name        = "/ghost/dbpassw"
  description = "ghost db password"
  type        = "SecureString"
  value       = var.aws_rds_password
}