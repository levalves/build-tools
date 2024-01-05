terraform {
  backend "s3" {
    region = "us-east-1"
    bucket = "levalves-terraform-tfstates"
    key    = "powerbi/terraform.tfstate"
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      product     = var.product
      env         = var.environment
      application = var.application
      terraform   = var.terraform
    }
  }
}