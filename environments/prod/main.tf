# Provider + module call for dev
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "ec2" {
  source = "../../modules/ec2"

  environment                   = "prod"
  instance_type                 = var.instance_type
  allowed_ssh_cidr              = var.allowed_ssh_cidr
  enable_termination_protection = true # Enable termination protection for the EC2 instance in PROD
}
