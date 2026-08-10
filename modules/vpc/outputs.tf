# This is the outputs.tf file for the VPC module which provides a VPC with public and private subnets and a NAT Gateway

# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.this.id
}

# Output the public subnet IDs
output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

# Output the private subnet IDs
output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}