
variable "profile" {
  type        = string
  description = "AWS profile to use"
}

variable "region_one" {
  type        = string
  description = "First AWS region"
}

variable "region_two" {
  type        = string
  description = "Second AWS region"
}

variable "vpc_one_cidr" {
  type        = string
  description = "CIDR block for VPC in region one"
}

variable "vpc_one_subnet_count" {
  type        = number
  description = "Number of subnets in VPC one"
}

variable "vpc_one_subnet_cidrs" {
  type        = list(string)
  description = "Subnet CIDR blocks for VPC one"
}

variable "vpc_one_azs" {
  type        = list(string)
  description = "Availability zones for VPC one subnets"
  default     = []
}

variable "vpc_one_route_table_count" {
  type        = number
  description = "Number of route tables for VPC one"
  default     = 1
}

variable "vpc_one_create_igw" {
  type        = bool
  description = "Create Internet Gateway for VPC one"
  default     = true
}

variable "vpc_two_cidr" {
  type        = string
  description = "CIDR block for VPC in region two"
}

variable "vpc_two_subnet_count" {
  type        = number
  description = "Number of subnets in VPC two"
}

variable "vpc_two_subnet_cidrs" {
  type        = list(string)
  description = "Subnet CIDR blocks for VPC two"
}

variable "vpc_two_azs" {
  type        = list(string)
  description = "Availability zones for VPC two subnets"
  default     = []
}

variable "vpc_two_route_table_count" {
  type        = number
  description = "Number of route tables for VPC two"
  default     = 1
}

variable "vpc_two_create_igw" {
  type        = bool
  description = "Create Internet Gateway for VPC two"
  default     = true
}
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name_region_one" {
  type        = string
  description = "Key pair name for region one"
}

variable "key_name_region_two" {
  type        = string
  description = "Key pair name for region two"
}
