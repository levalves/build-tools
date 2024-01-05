resource "aws_security_group" "powerbi" {
  name        = "allow_powerbi"
  description = "Power BI Allow inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow ports Power BI"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow ports Power BI"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}