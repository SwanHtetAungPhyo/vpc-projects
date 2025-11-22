output "vpc_one_id" {
  value       = module.vpc_region_one.vpc_id
  description = "VPC ID for region one"
}

output "vpc_one_subnet_ids" {
  value       = module.vpc_region_one.subnet_ids
  description = "Subnet IDs for region one"
}

output "vpc_one_route_table_ids" {
  value       = module.vpc_region_one.route_table_ids
  description = "Route table IDs for region one"
}

output "vpc_two_id" {
  value       = module.vpc_region_two.vpc_id
  description = "VPC ID for region two"
}

output "vpc_two_subnet_ids" {
  value       = module.vpc_region_two.subnet_ids
  description = "Subnet IDs for region two"
}

output "vpc_two_route_table_ids" {
  value       = module.vpc_region_two.route_table_ids
  description = "Route table IDs for region two"
}

# VPC Peering Outputs
output "peering_connection_id" {
  value       = aws_vpc_peering_connection.peer_connection.id
  description = "VPC Peering Connection ID"
}

output "peering_status" {
  value       = aws_vpc_peering_connection.peer_connection.accept_status
  description = "VPC Peering Connection Status"
}