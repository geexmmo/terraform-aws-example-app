terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.19.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.17.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

##
# Data
##
data "aws_availability_zones" "available" {
  state = "available"
}

# data "aws_caller_identity" "current" {}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_ami" "amazon-linux-2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-hvm-*-x86_64-gp2"]
  }
}

data "aws_key_pair" "geexmmo" {
  key_name = "geexmmo"
}
## VPC DATA
data "aws_vpcs" "cloudx" {
  tags = {
    "Name" = "cloudx"
  }
}
# public
data "aws_subnets" "cloudx" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.cloudx.ids
  }
  filter {
    name   = "tag:Type"
    values = ["Public"]
  }
}
data "aws_subnet" "cloudx" {
  for_each = toset(data.aws_subnets.cloudx.ids)
  id       = each.value
}
# private
data "aws_subnets" "cloudx-private" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.cloudx.ids
  }
  filter {
    name   = "tag:Type"
    values = ["Private"]
  }
}
data "aws_subnet" "cloudx-private" {
  for_each = toset(data.aws_subnets.cloudx-private.ids)
  id       = each.value
}
# ECSPrivate
data "aws_subnets" "ecs-private" {
  filter {
    name   = "vpc-id"
    values = data.aws_vpcs.cloudx.ids
  }
  filter {
    name   = "tag:Type"
    values = ["ECSPrivate"]
  }
}
data "aws_subnet" "ecs-private" {
  for_each = toset(data.aws_subnets.ecs-private.ids)
  id       = each.value
}

# ##
# # Output ALB URL
# ##
# output "ALB_result" {
#   value = [aws_lb.ghost-alb.dns_name]
# }