terraform {
  required_version = "1.3.3"
  required_providers {
    aws = "~>4"
  }
}

######
# VPC
######
resource "aws_vpc" "vpc" {
  #checkov:skip=CKV2_AWS_11:"Ensure VPC flow logging is enabled in all VPCs"
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

##################
# Internet Gateway
##################
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.environment}-igw"

  }
}


#####################
# EIP For Nat Gateway
#####################
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig] # Wait for IGW creation
}


#############
# NAT Gateway
#############
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id # Bind EIP
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)

  tags = {
    Name = "${var.environment}-natGW"
  }
}


##################
# Public subnet(s)
##################
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.public_subnets_cidr)
  cidr_block        = element(var.public_subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.environment}-${element(var.availability_zones, count.index)}-public-subnet"
  }
}
###################
# Private subnet(s)
###################
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.private_subnets_cidr)
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)


  tags = {
    Name = "${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
  }
}

###################################
# Routing Table For Private Subnets
###################################
resource "aws_route_table" "private_RT" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-private-route-table"
  }
}

###################################
# Routing Table For Public Subnets
###################################
resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-public-route-table"
  }
}
############################
# Route For Internet Gateway
############################
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}
#######################
# Route For NAT Gateway
#######################
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_RT.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

##########################
# Route Table Associations
##########################
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_RT.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_RT.id
}

################################
# Default Security Group For VPC
################################
resource "aws_default_security_group" "default" {

  vpc_id = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]


  tags = {
    Name = "${var.environment}-default_SG"
  }
}
