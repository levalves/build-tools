# resource "aws_instance" "powerbi" {
#   ami                         = var.ami_id
#   instance_type               = var.instance_type
#   key_name                    = var.key_name
#   subnet_id                   = var.subnet_id
#   vpc_security_group_ids      = [aws_security_group.powerbi.id]
#   associate_public_ip_address = true
# }

# module "ec2_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "5.5.0"

#   name = var.application

#   ami                         = var.ami_id
#   instance_type               = var.instance_type
#   key_name                    = var.key_name
#   subnet_id                   = var.subnet_id
#   vpc_security_group_ids      = [aws_security_group.powerbi.id]
#   associate_public_ip_address = true
# }