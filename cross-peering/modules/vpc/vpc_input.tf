variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in the VPC"
  default     = true
}

variable "subnet_count" {
  type        = number
  description = "Number of subnets to create"
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for subnets"
  default     = []
}

variable "route_table_count" {
  type        = number
  description = "Number of route tables to create"
  default     = 1
}

variable "create_igw" {
  type        = bool
  description = "Create an Internet Gateway"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for resources"
  default     = {}
}