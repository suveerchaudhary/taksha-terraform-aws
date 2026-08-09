terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# The network itself
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "practice-vpc" }
}

# Internet Gateway - what makes public subnets "public"
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "practice-igw" }
}

# Public subnets - one per AZ, /24 each (256 IPs)
resource "aws_subnet" "public" {
  for_each                = { for idx, az in var.azs : az => idx }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value) # 10.0.0.0/24, 10.0.1.0/24...
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags                    = { Name = "public-${each.key}" }
}

# Private subnets - one per AZ, offset into the second half of the range
resource "aws_subnet" "private" {
  for_each          = { for idx, az in var.azs : az => idx }
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value + 100) # 10.0.100.0/24, 10.0.101.0/24...
  availability_zone = each.key
  tags              = { Name = "private-${each.key}" }
}

# Public route table - sends 0.0.0.0/0 (all internet traffic) to the IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway - COSTS MONEY WHILE IT EXISTS (~$0.045/hr + data processing).
# Needs an Elastic IP and must sit in a PUBLIC subnet (it's the "exit door"
# private resources route through). One NAT here, not one per AZ, to keep
# cost down for a practice session - real prod setups often use one per AZ
# for redundancy, at proportionally higher cost.
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "practice-nat-eip" }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id
  tags          = { Name = "practice-nat" }
  depends_on    = [aws_internet_gateway.this]
}

# Private route table - sends 0.0.0.0/0 to the NAT (outbound-only internet)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}