output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = aws_vpc.this.cidr_block
  description = "VPC CIDR block"
}

output "subnet_ids" {
  value       = aws_subnet.subnets[*].id
  description = "List of subnet IDs"
}

output "route_table_ids" {
  value       = aws_route_table.route_tables[*].id
  description = "List of route table IDs"
}

output "igw_id" {
  value       = var.create_igw ? aws_internet_gateway.igw[0].id : null
  description = "Internet Gateway ID"
}