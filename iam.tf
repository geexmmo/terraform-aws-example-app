##
# IAM Doc, Policy, Role
##
# resource "aws_iam_instance_profile" "ghost-app-instanceprofile" {
#   name = "ghost"
#   role = aws_iam_role.ghost-app-role.name
# }
resource "aws_iam_instance_profile" "ecs-ip" {
  name = "ecs"
  role = aws_iam_role.ecs-role.name
}
# resource "aws_iam_policy" "ghost-app-policy" {
#   name = "ghost-app-policy"
#   # role = aws_iam_role.ghost_app_role.id
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Sid" : "",
#         "Effect" : "Allow",
#         "Action" : [
#           "ec2:DescribeAddressesAttribute",
#           "elasticfilesystem:DescribeFileSystems",
#           "elasticfilesystem:ClientMount",
#           "elasticfilesystem:ClientWrite",
#           "ssm:GetParameter*",
#           "secretsmanager:GetSecretValue",
#           "kms:Decrypt",
#           "rds:DescribeDBInstances",
#           "elasticloadbalancing:DescribeLoadBalancers"
#         ]
#         "Resource" : "*"
#       }
#     ]
#   })
# }
resource "aws_iam_policy" "ecs-policy" {
  name = "ecs-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        "Resource" : "*"
      }
    ]
  })
}

# data "aws_iam_policy_document" "instance-assume-role-policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }

data "aws_iam_policy_document" "ecs-pd" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# resource "aws_iam_role" "ghost-app-role" {
#   name                = "ghost-app-role"
#   assume_role_policy  = data.aws_iam_policy_document.instance-assume-role-policy.json
#   managed_policy_arns = [aws_iam_policy.ghost-app-policy.arn]
# }

resource "aws_iam_role" "ecs-role" {
  name                = "ecs-role"
  assume_role_policy  = data.aws_iam_policy_document.ecs-pd.json
  managed_policy_arns = [aws_iam_policy.ecs-policy.arn]
}