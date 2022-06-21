##
# ASG
##
resource "aws_autoscaling_group" "cloudx-asg" {
  #   availability_zones = [for s in data.aws_subnet.example : s.availability_zone]
  name                = "ghost-asg"
  vpc_zone_identifier = [for s in data.aws_subnet.cloudx : s.id]
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.ghost-ec2.arn]

  launch_template {
    id      = aws_launch_template.ghost-template.id
    version = "$Latest"
  }
}