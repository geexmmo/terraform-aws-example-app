variable "aws_rds_username" {
  description = "AWS RDS Username"
  type        = string
  default     = "dbadminghost"
}
variable "aws_rds_password" {
  description = "AWS RDS Password"
  type        = string
  default     = "NYied$UPL##9ui"
}

variable "ghost_docker_image" {
  description = "Ghost Docker image"
  type        = string
  default     = "ghost:4.12.1"
}