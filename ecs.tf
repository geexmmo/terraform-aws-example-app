resource "aws_ecs_cluster" "ghost" {
  name = "ghost-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "ghost" {
  family                   = "ghost-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs-role.arn
  memory                   = 2048
  cpu                      = 1024
  volume {
    name = "ghost-content"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.ghost_content.id
      root_directory = "/"
    }
  }
  container_definitions = <<DEFINITION
  [
    {
      "name" : "ghost-task",
      "image" : "${aws_ecr_repository.ghost.repository_url}:latest",
      "essential" : true,
      "environment" : [
        { "name" : "database__client", "value" : "mysql" },
        { "name" : "database__connection__host", "value" : "${aws_db_instance.cloudx.address}" },
        { "name" : "database__connection__user", "value" : "${var.aws_rds_username}" },
        { "name" : "database__connection__password", "value" : "${var.aws_rds_password}" },
        { "name" : "database__connection__database", "value" : "${aws_db_instance.cloudx.db_name}" }
      ],
      "mountPoints" : [
        {
          "containerPath" : "/var/lib/ghost/content",
          "sourceVolume" : "ghost-content"
        }
      ],
      "portMappings" : [
        {
          "containerPort" : 2368,
          "hostPort" : 2368
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "ghost-ecr-containers-group",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "ghost" {
  name            = "ghost-service"
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.ghost.arn
  cluster         = aws_ecs_cluster.ghost.id
  depends_on      = [aws_iam_role.ecs-role]
  desired_count = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.ghost-ecs.arn
    container_name   = "ghost-task"
    container_port   = 2368
  }
  network_configuration {
    subnets          = [for s in data.aws_subnet.ecs-private : s.id]
    security_groups  = [aws_security_group.fargate_pool.id]
  }
}