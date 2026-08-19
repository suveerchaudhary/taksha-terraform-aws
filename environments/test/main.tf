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

module "vpc" {
  source = "../../modules/vpc"

  environment = "test"
  vpc_cidr    = "10.1.0.0/16" # CIDR block for the VPC , 0 for dev, 1 for test, 2 for prod
  enable_nat  = var.enable_nat
}

module "ec2" {
  source = "../../modules/ec2"

  environment      = "test"
  instance_type    = var.instance_type
  allowed_ssh_cidr = var.allowed_ssh_cidr
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnet_ids[0]
}
