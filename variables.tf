variable "environment" {
  default = "production"
}
variable "region" {
  default = "us-east-1"
}

variable "application" {
  default = "powe-bi-gw"
}

variable "product" {
  default = "power-bi"
}

variable "terraform" {
  description = "Inform if the resource is being created by terraform."
  default     = true
}

variable "vpc_id" {
  default = "vpc-2e2dcb53"
}

variable "subnet_id" {
  default = "subnet-af0c1591"
}

variable "ami_id" {
  default = "ami-005f8adf84f8c5057"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "kp-ec2-win-us-east-1"
}
