terraform { 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.19.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

##
# Data
##
data "aws_availability_zones" "available" {
  state = "available"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_ami" "amazon-linux-2" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-hvm-*-x86_64-gp2"]
  }
}

data "aws_key_pair" "geexmmo" {
  key_name = "geexmmo"
}
##
# VPC
##
resource "aws_vpc" "cloudx" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"
  enable_dns_support=true
  enable_dns_hostnames=true
  tags = {
    Name = "cloudx"
  }
}

resource "aws_subnet" "cloudx_a" {
  vpc_id     = aws_vpc.cloudx.id
  cidr_block = "10.10.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "cloudx_a",
    Type = "Public"
  }
}

resource "aws_subnet" "cloudx_b" {
  vpc_id     = aws_vpc.cloudx.id
  cidr_block = "10.10.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "cloudx_b",
    Type = "Public"
  }
}

resource "aws_subnet" "cloudx_c" {
  vpc_id     = aws_vpc.cloudx.id
  cidr_block = "10.10.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "cloudx_c",
    Type = "Public"
  }
}

resource "aws_internet_gateway" "gwcloudx" {
  vpc_id = aws_vpc.cloudx.id
  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "rtcloudx" {
  vpc_id = aws_vpc.cloudx.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gwcloudx.id
  }

  tags = {
    Name = "cloudx-rt"
  }
}
resource "aws_route_table_association" "cloudx_a" {
  subnet_id      = aws_subnet.cloudx_a.id
  route_table_id = aws_route_table.rtcloudx.id
}
resource "aws_route_table_association" "cloudx_b" {
  subnet_id      = aws_subnet.cloudx_b.id
  route_table_id = aws_route_table.rtcloudx.id
}
resource "aws_route_table_association" "cloudx_c" {
  subnet_id      = aws_subnet.cloudx_c.id
  route_table_id = aws_route_table.rtcloudx.id
}
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
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id = aws_security_group.ec2_pool.id
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
  type              = "ingress"
  from_port         = 2368
  to_port           = 2368
  protocol          = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id = aws_security_group.ec2_pool.id
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
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = aws_security_group.ec2_pool.id
  security_group_id = aws_security_group.alb.id
}
## efs
resource "aws_security_group_rule" "efs_in_efs_ec2_pool" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  source_security_group_id = aws_security_group.ec2_pool.id
  security_group_id = aws_security_group.efs.id
}
resource "aws_security_group_rule" "efs_egress_vpc" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = [aws_vpc.cloudx.cidr_block]
  security_group_id = aws_security_group.efs.id
}
## VPC DATA
data "aws_vpcs" "cloudx" {
  tags = {
    "Name" = "cloudx"
  }
}
data "aws_subnets" "cloudx" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.cloudx.ids
  }
  filter {
    name = "tag:Type"
    values = ["Public"]
  }
}
data "aws_subnet" "cloudx" {
  for_each = toset(data.aws_subnets.cloudx.ids)
  id       = each.value
}
##
# IAM Doc, Policy, Role
##
resource "aws_iam_instance_profile" "ghost-app-instanceprofile" {
  name="ghost"
  role = aws_iam_role.ghost-app-role.name  
}
resource "aws_iam_policy" "ghost-app-policy" {
  name = "ghost-app-policy"
  # role = aws_iam_role.ghost_app_role.id
  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "",
              "Effect": "Allow",
              "Action": [
                "ec2:DescribeAddressesAttribute",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
                ]
              "Resource": "*"
          }
      ]
  })
}
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ghost-app-role" {
  name = "ghost-app-role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  managed_policy_arns = [aws_iam_policy.ghost-app-policy.arn]
}
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
  file_system_id = aws_efs_file_system.ghost_content.id
  subnet_id      = aws_subnet.cloudx_a.id
  security_groups = [aws_security_group.efs.id]
}
resource "aws_efs_mount_target" "cloudx_b" {
  file_system_id = aws_efs_file_system.ghost_content.id
  subnet_id      = aws_subnet.cloudx_b.id
  security_groups = [aws_security_group.efs.id]
}
resource "aws_efs_mount_target" "cloudx_c" {
  file_system_id = aws_efs_file_system.ghost_content.id
  subnet_id      = aws_subnet.cloudx_c.id
  security_groups = [aws_security_group.efs.id]
}
##
# ALB
##
## tg
resource "aws_lb_target_group" "ghost-ec2" {
  name     = "ghost-ec2"
  port     = 2368
  protocol = "HTTP"
  vpc_id   = aws_vpc.cloudx.id
}
## alb
resource "aws_lb" "ghost-alb" {
  name               = "ghost-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for s in data.aws_subnet.cloudx : s.id]
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ghost-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ghost-ec2.arn
  }
}
##
# Launch Template
##
resource "aws_launch_template" "ghost-template" {
  name = "ghost-template"
  update_default_version = true
  iam_instance_profile {
    name = aws_iam_instance_profile.ghost-app-instanceprofile.name
  }
  image_id = data.aws_ami.amazon-linux-2.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_market_options {
    market_type = "spot"
  }
  instance_type = "t2.micro"
  key_name = data.aws_key_pair.geexmmo.key_name
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.ec2_pool.id]
  }

  # vpc_security_group_ids = [aws_security_group.ec2_pool.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ghost-worker"
    }
  }

  user_data = filebase64("./ghost.sh")
}
##
# ASG
##
resource "aws_autoscaling_group" "cloudx-asg" {
#   availability_zones = [for s in data.aws_subnet.example : s.availability_zone]
  name = "ghost-asg"
  vpc_zone_identifier = [for s in data.aws_subnet.cloudx : s.id]
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2
  target_group_arns = [ aws_lb_target_group.ghost-ec2.arn ]

  launch_template {
    id      = aws_launch_template.ghost-template.id
    version = "$Latest"
  }
}
# resource "aws_autoscaling_attachment" "cloudx-asg-attachment" {
#   autoscaling_group_name = aws_autoscaling_group.cloudx-asg.name
#   lb_target_group_arn    = aws_lb_target_group.ghost-ec2.arn
# }
##
# Bastion
##
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  key_name = data.aws_key_pair.geexmmo.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id = aws_subnet.cloudx_a.id
  associate_public_ip_address = true
  #source_dest_check = false
  tags = {
    Name = "bastion"
  }
}

##
# Output ALB URL
##
output "ALB_result" {
  value = [aws_lb.ghost-alb.dns_name]
}