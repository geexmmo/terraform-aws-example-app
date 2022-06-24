# ##
# # Launch Template
# ##
# resource "aws_launch_template" "ghost-template" {
#   name                   = "ghost-template"
#   update_default_version = true
#   iam_instance_profile {
#     name = aws_iam_instance_profile.ghost-app-instanceprofile.name
#   }
#   image_id                             = data.aws_ami.amazon-linux-2.id
#   instance_initiated_shutdown_behavior = "terminate"
#   instance_market_options {
#     market_type = "spot"
#   }
#   instance_type = "t2.micro"
#   key_name      = data.aws_key_pair.geexmmo.key_name
#   network_interfaces {
#     associate_public_ip_address = true
#     security_groups             = [aws_security_group.ec2_pool.id]
#   }

#   # vpc_security_group_ids = [aws_security_group.ec2_pool.id]

#   tag_specifications {
#     resource_type = "instance"

#     tags = {
#       Name = "ghost-worker"
#     }
#   }

#   user_data = filebase64("./ghostv2.sh")
# }
