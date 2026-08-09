variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# Two AZs - realistic minimum for demonstrating redundancy
variable "azs" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b"]
}