##
# Bastion
##
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = "t2.micro"
  key_name                    = data.aws_key_pair.geexmmo.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = aws_subnet.cloudx_a.id
  iam_instance_profile = aws_iam_instance_profile.ecs-ip.name
  associate_public_ip_address = true
  source_dest_check = false
  user_data = filebase64("./natinstance.sh")
  tags = {
    Name = "bastion"
  }
}

resource "aws_instance" "test" {
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = "t2.micro"
  key_name                    = data.aws_key_pair.geexmmo.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = aws_subnet.private_a.id
  iam_instance_profile = aws_iam_instance_profile.ecs-ip.name
  tags = {
    Name = "test"
  }
}