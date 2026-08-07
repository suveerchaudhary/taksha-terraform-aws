# Inputs for the dev environment
variable "instance_type" {
  type    = string
  default = "t3.nano"
  description = "The type of instance to use for the EC2 instance"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "Your IP in CIDR form, e.g. 203.0.113.4/32"
}
