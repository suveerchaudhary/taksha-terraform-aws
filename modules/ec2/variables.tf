# This is the variables.tf file for the EC2 module which provides an EC2 instance

# Inputs every environment passes in when using this module
variable "environment" {
  type        = string
  description = "dev | test | prod"
}

# Instance type for the EC2 instance
variable "instance_type" {
  type    = string
  default = "t3.nano"
}

# Allowed SSH CIDR for the EC2 instance
variable "allowed_ssh_cidr" {
  type        = string
  description = "Your IP in CIDR form, e.g. 203.0.113.4/32"
}

# Whether to enable termination protection for the EC2 instance
variable "enable_termination_protection" {
  type        = bool
  description = "If true, enables EC2 instance termination protection"
  default     = false
}

# VPC ID for the EC2 instance
variable "vpc_id" {
  type = string
}

# Subnet ID for the EC2 instance
variable "subnet_id" {
  type = string
}