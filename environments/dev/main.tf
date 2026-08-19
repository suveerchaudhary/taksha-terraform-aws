# This is the entry point for the dev environment and act as the driver.
# It list down modules called by this environment. Whichever module is called by this main.tf, are provisioned in this environment.

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

# EC2 module call for dev
module "ec2" {
  source = "../../modules/ec2"

  environment      = "dev"
  instance_type    = var.instance_type
  allowed_ssh_cidr = var.allowed_ssh_cidr
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnet_ids[0]
}

# VPC module call for dev
module "vpc" {
  source = "../../modules/vpc"

  environment = "dev"
  vpc_cidr    = "10.0.0.0/16" # CIDR block for the VPC , 0 for dev, 1 for test, 2 for prod
  enable_nat  = var.enable_nat
}

# EKS module call for dev
module "eks" {
  source = "../../modules/eks"

  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
}