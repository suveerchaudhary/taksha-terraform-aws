# This is the variables.tf file for the VPC module which provides a VPC with public and private subnets and a NAT Gateway

# Inputs every environment passes in when using this module
variable "environment" {
  type        = string
  description = "dev | test | prod"
}

# CIDR block for the VPC
variable "vpc_cidr" {
  type = string
}

# Availability Zones for the VPC
variable "azs" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b"]
}

# Whether to enable NAT Gateway for private subnets
variable "enable_nat" {
  type    = bool
  default = true
}