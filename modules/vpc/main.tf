# This is the main.tf file for the VPC module which provides a VPC with public and private subnets and a NAT Gateway

# Create the VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.environment}-vpc" }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.environment}-igw" }
}

# Create the public subnets
resource "aws_subnet" "public" {
  for_each                = { for idx, az in var.azs : az => idx }
  vpc_id                   = aws_vpc.this.id
  cidr_block               = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone         = each.key
  map_public_ip_on_launch  = true
  tags                     = { Name = "${var.environment}-public-${each.key}" }
}

# Create the private subnets
resource "aws_subnet" "private" {
  for_each          = { for idx, az in var.azs : az => idx }
  vpc_id             = aws_vpc.this.id
  cidr_block         = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone   = each.key
  tags               = { Name = "${var.environment}-private-${each.key}" }
}

# Create the public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.this.id
  }
  tags = { Name = "${var.environment}-public-rt" }
}

# Create the public route table association
resource "aws_route_table_association" "public" {
  for_each        = aws_subnet.public
  subnet_id        = each.value.id
  route_table_id  = aws_route_table.public.id
}

# Create the NAT Elastic IP
resource "aws_eip" "nat" {
  count  = var.enable_nat ? 1 : 0
  domain = "vpc"
  tags   = { Name = "${var.environment}-nat-eip" }
}

# Create the NAT Gateway
resource "aws_nat_gateway" "this" {
  count          = var.enable_nat ? 1 : 0
  allocation_id  = aws_eip.nat[0].id
  subnet_id       = values(aws_subnet.public)[0].id
  tags           = { Name = "${var.environment}-nat" }
  depends_on     = [aws_internet_gateway.this]
}

# Create the private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  dynamic "route" {
    for_each = var.enable_nat ? [1] : []
    content {
      cidr_block      = "0.0.0.0/0"
      nat_gateway_id  = aws_nat_gateway.this[0].id
    }
  }
  tags = { Name = "${var.environment}-private-rt" }
}

# Create the private route table association
resource "aws_route_table_association" "private" {
  for_each        = aws_subnet.private
  subnet_id        = each.value.id
  route_table_id  = aws_route_table.private.id
}