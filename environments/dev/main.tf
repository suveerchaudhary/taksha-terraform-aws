# Provider + module call for dev
# testing PR workflow - if this file is changed, the PR workflow will run
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

  environment      = "dev"
  instance_type    = var.instance_type
  allowed_ssh_cidr = var.allowed_ssh_cidr
  description      = "EC2 instance for the dev environment"
}
