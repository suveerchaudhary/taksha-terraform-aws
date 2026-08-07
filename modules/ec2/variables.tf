# Inputs every environment passes in when using this module
variable "environment" {
  type        = string
  description = "dev | test | prod"
}

variable "instance_type" {
  type    = string
  default = "t3.nano"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "Your IP in CIDR form, e.g. 203.0.113.4/32"
}