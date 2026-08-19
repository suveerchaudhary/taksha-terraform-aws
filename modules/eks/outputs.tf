# This is the outputs.tf file for the EKS module which provides an EKS cluster and a node group.

# Output the cluster name
output "cluster_name" {
  value = aws_eks_cluster.this.name
}

# Output the cluster endpoint
output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}