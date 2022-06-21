##
# EFS
##
resource "aws_efs_file_system" "ghost_content" {
  creation_token = "lab-efs"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "ghost_content"
  }
}

resource "aws_efs_mount_target" "cloudx_a" {
  file_system_id  = aws_efs_file_system.ghost_content.id
  subnet_id       = aws_subnet.cloudx_a.id
  security_groups = [aws_security_group.efs.id]
}
resource "aws_efs_mount_target" "cloudx_b" {
  file_system_id  = aws_efs_file_system.ghost_content.id
  subnet_id       = aws_subnet.cloudx_b.id
  security_groups = [aws_security_group.efs.id]
}
resource "aws_efs_mount_target" "cloudx_c" {
  file_system_id  = aws_efs_file_system.ghost_content.id
  subnet_id       = aws_subnet.cloudx_c.id
  security_groups = [aws_security_group.efs.id]
}