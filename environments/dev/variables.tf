# Inputs for the dev environment
variable "instance_type" {
  type        = string
  default     = "t3.nano"
  description = "The type of instance to use for the EC2 instance"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "Your IP in CIDR form, e.g. 203.0.113.4/32"
}

# Whether to enable NAT Gateway for private subnets
variable "enable_nat" {
  type = bool
  #default to  false,NAT suppressed, cost-safe by default. Each instance is 1 hour charged for NAT usage.
  default = false
}

# Whether to enable EKS
variable "enable_eks" {
  type    = bool
  default = false # EKS is not enabled by default
}

# IAM principals granted EKS cluster-admin via access entries (see modules/eks)
variable "cluster_admin_arns" {
  type        = list(string)
  description = "IAM user/role ARNs granted AmazonEKSClusterAdminPolicy on the EKS cluster"
  default     = []
}