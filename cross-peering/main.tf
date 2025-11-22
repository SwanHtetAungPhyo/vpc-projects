terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.22.1"
    }
  }
}
provider "aws" {
  profile = var.profile
  region  = var.region_one
  alias   = "region-one"
}

provider "aws" {
  profile = var.profile
  region  = var.region_two
  alias   = "region-two"
}

module "vpc_region_one" {
  source = "./modules/vpc"

  providers = {
    aws = aws.region-one
  }


  vpc_name             = "VPC-1"
  vpc_cidr             = var.vpc_one_cidr
  subnet_count         = var.vpc_one_subnet_count
  subnet_cidrs         = var.vpc_one_subnet_cidrs
  availability_zones   = var.vpc_one_azs
  route_table_count    = var.vpc_one_route_table_count
  create_igw           = var.vpc_one_create_igw

  tags = {
    Environment = "production"
    Region      = var.region_one
  }
}

module "vpc_region_two" {
  source = "./modules/vpc"

  providers = {
    aws = aws.region-two
  }

  vpc_name             = "VPC-2"
  vpc_cidr             = var.vpc_two_cidr
  subnet_count         = var.vpc_two_subnet_count
  subnet_cidrs         = var.vpc_two_subnet_cidrs
  availability_zones   = var.vpc_two_azs
  route_table_count    = var.vpc_two_route_table_count
  create_igw           = var.vpc_two_create_igw

  tags = {
    Environment = "production"
    Region      = var.region_two
  }
}
resource "aws_vpc_peering_connection" "peer_connection" {
  provider    = aws.region-one
  vpc_id      = module.vpc_region_one.vpc_id
  peer_vpc_id = module.vpc_region_two.vpc_id
  peer_region = var.region_two
  auto_accept = false

  tags = {
    Name        = "VPC1-to-VPC2-Peering"
    Side        = "Requester"
    Environment = "production"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  provider                  = aws.region-two
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection.id
  auto_accept               = true

  tags = {
    Name        = "VPC1-to-VPC2-Peering"
    Side        = "Accepter"
    Environment = "production"
  }
}

resource "aws_route" "vpc_one_to_vpc_two" {
  provider                  = aws.region-one
  count                     = length(module.vpc_region_one.route_table_ids)
  route_table_id            = module.vpc_region_one.route_table_ids[count.index]
  destination_cidr_block    = var.vpc_two_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection.id
}

resource "aws_route" "vpc_two_to_vpc_one" {
  provider                  = aws.region-two
  count                     = length(module.vpc_region_two.route_table_ids)
  route_table_id            = module.vpc_region_two.route_table_ids[count.index]
  destination_cidr_block    = var.vpc_one_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection.id
  depends_on = [aws_vpc_peering_connection_accepter.peer_accepter]
}