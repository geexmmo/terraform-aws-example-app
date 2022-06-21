
##
# SG
##
resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "allows access to bastion"
  vpc_id      = aws_vpc.cloudx.id
  tags = {
    Name = "bastion"
  }
}

resource "aws_security_group" "ec2_pool" {
  name        = "ec2_pool"
  description = "allows access to ec2 instances"
  vpc_id      = aws_vpc.cloudx.id
  tags = {
    Name = "ec2_pool"
  }
}

resource "aws_security_group" "alb" {
  name        = "alb"
  description = "allows access to ec2 instances"
  vpc_id      = aws_vpc.cloudx.id
  tags = {
    Name = "alb"
  }
}

resource "aws_security_group" "efs" {
  name        = "efs"
  description = "defines access to efs mount points"
  vpc_id      = aws_vpc.cloudx.id
  tags = {
    Name = "efs"
  }
}

resource "aws_security_group" "mysql" {
  name        = "mysql"
  description = "defines access to db"
  vpc_id      = aws_vpc.cloudx.id
  tags = {
    Name = "mysql"
  }
}

##
# SG RULES
##

## bastion
resource "aws_security_group_rule" "bastion_in_ssh_me" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = aws_security_group.bastion.id
}
resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}
## ec2_pool
resource "aws_security_group_rule" "ec2_pool_in_ssh_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.ec2_pool.id
}
resource "aws_security_group_rule" "ec2_pool_in_efs_vpc" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.cloudx.cidr_block]
  security_group_id = aws_security_group.ec2_pool.id
}
resource "aws_security_group_rule" "ec2_pool_in_app_alb" {
  type                     = "ingress"
  from_port                = 2368
  to_port                  = 2368
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2_pool.id
}
resource "aws_security_group_rule" "ec2_pool_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_pool.id
}
## alb
resource "aws_security_group_rule" "alb_http_myip" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = aws_security_group.alb.id
}
resource "aws_security_group_rule" "alb_egress_ec2_pool" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.ec2_pool.id
  security_group_id        = aws_security_group.alb.id
}
## efs
resource "aws_security_group_rule" "efs_in_efs_ec2_pool" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_pool.id
  security_group_id        = aws_security_group.efs.id
}
resource "aws_security_group_rule" "efs_egress_vpc" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.cloudx.cidr_block]
  security_group_id = aws_security_group.efs.id
}

## mysql
resource "aws_security_group_rule" "mysql_in_ec2_pool" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_pool.id
  security_group_id        = aws_security_group.mysql.id
}

resource "aws_security_group_rule" "mysql_egress_mysql" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.mysql.id
  security_group_id        = aws_security_group.mysql.id
}