# This is the variables.tf file for the EKS module which provides an EKS cluster and a node group.

# Environment for the EKS cluster
variable "environment" {
  type = string
}

# VPC ID for the EKS cluster
variable "vpc_id" {
  type = string
}

# Private subnet IDs for the EKS cluster
variable "private_subnet_ids" {
  type = list(string)
}

# Public subnet IDs for the EKS cluster
variable "public_subnet_ids" {
  type = list(string)
}

# Node instance type for the EKS cluster. t3.small is the practical minimum - nano/micro can't run EKS's kubelet overhead
variable "node_instance_type" {
  type    = string
  default = "t3.small"
}

# IAM user/role ARNs to grant cluster-admin access to
variable "cluster_admin_arns" {
  type        = list(string)
  description = "IAM user/role ARNs to grant cluster-admin access to"
  default     = []
}