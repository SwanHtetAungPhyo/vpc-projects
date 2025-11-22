
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

# Security Group for VPC 1
resource "aws_security_group" "vpc_one_sg" {
  provider    = aws.region-one
  name        = "vpc-one-test-sg"
  description = "Security group for VPC 1 test instance"
  vpc_id      = module.vpc_region_one.vpc_id

  ingress {
    description = "HTTP from VPC 2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_two_cidr]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from VPC 2"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_two_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-one-test-sg"
  }
}

resource "aws_security_group" "vpc_two_sg" {
  provider    = aws.region-two
  name        = "vpc-two-test-sg"
  description = "Security group for VPC 2 test instance"
  vpc_id      = module.vpc_region_two.vpc_id

  ingress {
    description = "HTTP from VPC 1"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_one_cidr]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from VPC 1"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_one_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-two-test-sg"
  }
}

# Data source for AMI in region one
data "aws_ami" "amazon_linux_one" {
  provider    = aws.region-one
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source for AMI in region two
data "aws_ami" "amazon_linux_two" {
  provider    = aws.region-two
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance in VPC 1
resource "aws_instance" "vpc_one_instance" {
  provider                    = aws.region-one
  ami                         = data.aws_ami.amazon_linux_one.id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc_region_one.subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.vpc_one_sg.id]
  key_name                    = var.key_name_region_one
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from VPC 1 in ${var.region_one}</h1>" > /var/www/html/index.html
              echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
              EOF

  tags = {
    Name        = "VPC-1-Test-Instance"
    Environment = "production"
  }
}

# EC2 Instance in VPC 2
resource "aws_instance" "vpc_two_instance" {
  provider                    = aws.region-two
  ami                         = data.aws_ami.amazon_linux_two.id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc_region_two.subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.vpc_two_sg.id]
  key_name                    = var.key_name_region_two
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from VPC 2 in ${var.region_two}</h1>" > /var/www/html/index.html
              echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
              EOF

  tags = {
    Name        = "VPC-2-Test-Instance"
    Environment = "production"
  }
}
