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
resource "aws_lb_target_group" "ghost-ecs" {
  name        = "ghost-ecs"
  port        = 2368
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.cloudx.id
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

  #   default_action {
  #     type             = "forward"
  #     target_group_arn = aws_lb_target_group.ghost-ec2.arn
  #   }
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ghost-ecs.arn
  }
}