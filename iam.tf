##
# IAM Doc, Policy, Role
##
resource "aws_iam_instance_profile" "ghost-app-instanceprofile" {
  name = "ghost"
  role = aws_iam_role.ghost-app-role.name
}
resource "aws_iam_policy" "ghost-app-policy" {
  name = "ghost-app-policy"
  # role = aws_iam_role.ghost_app_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeAddressesAttribute",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "ssm:GetParameter*",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt",
          "rds:DescribeDBInstances",
          "elasticloadbalancing:DescribeLoadBalancers"
        ]
        "Resource" : "*"
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
  name                = "ghost-app-role"
  assume_role_policy  = data.aws_iam_policy_document.instance-assume-role-policy.json
  managed_policy_arns = [aws_iam_policy.ghost-app-policy.arn]
}