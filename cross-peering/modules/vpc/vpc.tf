terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
    }
  )
}

resource "aws_subnet" "subnets" {
  count      = var.subnet_count
  vpc_id     = aws_vpc.this.id
  cidr_block = var.subnet_cidrs[count.index]
  availability_zone = length(var.availability_zones) > 0 ? var.availability_zones[count.index % length(var.availability_zones)] : null

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-subnet-${count.index + 1}"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}

resource "aws_route_table" "route_tables" {
  count  = var.route_table_count
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-rt-${count.index + 1}"
    }
  )
}

resource "aws_route" "internet_route" {
  count                  = var.create_igw && var.route_table_count > 0 ? var.route_table_count : 0
  route_table_id         = aws_route_table.route_tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

resource "aws_route_table_association" "subnet_associations" {
  count          = min(var.subnet_count, var.route_table_count)
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.route_tables[count.index % var.route_table_count].id
}