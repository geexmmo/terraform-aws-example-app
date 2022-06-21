##
# Bastion
##
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = "t2.micro"
  key_name                    = data.aws_key_pair.geexmmo.key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = aws_subnet.cloudx_a.id
  associate_public_ip_address = true
  #source_dest_check = false
  tags = {
    Name = "bastion"
  }
}