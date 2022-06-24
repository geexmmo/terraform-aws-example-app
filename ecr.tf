# provider "docker" {
#   registry_auth {
#     address  = data.aws_ecr_authorization_token.token.proxy_endpoint
#     username = data.aws_ecr_authorization_token.token.user_name
#     password = data.aws_ecr_authorization_token.token.password
#   }
# }

# data "aws_ecr_authorization_token" "token" {
# }

data "aws_ecr_repository" "current" {
  name = aws_ecr_repository.ghost.name
}

resource "aws_ecr_repository" "ghost" {
  name                 = "ghost"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "local_file" "docekrfile" {
  content  = "FROM ${var.ghost_docker_image}"
  filename = "${path.cwd}/tmpdocker/Dockerfile"
  # file_permission = "0600"
}

# resource "docker_registry_image" "ghost" {
#   name = "${data.aws_ecr_repository.current.repository_url}:tag"
#   build {
#     context    = path.cwd
#     dockerfile = "tmpdocker/Dockerfile"
#   }
# }