terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Production-VPC"
    Tier = "Root"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "VPC-IGW"
  }
}

# All Subnets for all Environments
resource "aws_subnet" "all" {
  for_each                = { for s in var.all_subnets : s.cidr_block => s }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = data.aws_availability_zones.available.names[index(keys(var.all_subnets), each.key) % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = each.value.tier == "Public" # Only Public subnets get public IPs

  tags = {
    Name        = "subnet-${each.value.environment}-${each.value.tier}-${index(keys(var.all_subnets), each.key) + 1}"
    Tier        = each.value.tier
    Environment = each.value.environment
  }
}

# NAT Gateway
# place in first public Dev subnet
locals {
  nat_subnet_id = aws_subnet.all["10.0.1.0/24"].id 
}

resource "aws_eip" "nat_gateway" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "Vpc-NAT-EIP"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = local.nat_subnet_id
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name = "Vpc-NAT-Gateway"
  }
}

# Route Tables

# Public Route Table - routes all traffic to IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "Vpc-Public-RT" }
}

# Private Route Table - routes all traffic to NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = { Name = "Vpc-Private-RT" }
}

# Public subnets association
resource "aws_route_table_association" "public" {
  for_each       = { for cidr, subnet in aws_subnet.all : cidr => subnet.id if subnet.tags.Tier == "Public" }
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

# Private subnets association
resource "aws_route_table_association" "private" {
  for_each       = { for cidr, subnet in aws_subnet.all : cidr => subnet.id if subnet.tags.Tier == "Private" }
  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}