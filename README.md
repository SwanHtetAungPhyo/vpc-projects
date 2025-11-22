# Terraform AWS Cross-Region VPC Peering

This Terraform project sets up a VPC peering connection between two VPCs in different AWS regions. It also provisions an EC2 instance in each VPC to demonstrate connectivity.

## Prerequisites

Before you begin, ensure you have the following:

- AWS account with necessary permissions to create VPCs, EC2 instances, and related resources.
- AWS CLI configured with a profile.
- Terraform installed.
- An SSH key pair in each of the two regions you plan to use.

## Usage

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd <repository-directory>/cross-peering
    ```

2.  **Create a `terraform.tfvars` file:**

    Create a file named `terraform.tfvars` and populate it with the required variable values. See the Inputs section for details.

    **Example `terraform.tfvars`:**
    ```hcl
    profile             = "your-aws-profile"
    region_one          = "us-east-1"
    region_two          = "us-west-2"
    vpc_one_cidr        = "10.1.0.0/16"
    vpc_one_subnet_count = 2
    vpc_one_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
    vpc_one_azs         = ["us-east-1a", "us-east-1b"]
    vpc_two_cidr        = "10.2.0.0/16"
    vpc_two_subnet_count = 2
    vpc_two_subnet_cidrs = ["10.2.1.0/24", "10.2.2.0/24"]
    vpc_two_azs         = ["us-west-2a", "us-west-2b"]
    instance_type       = "t2.micro"
    key_name_region_one = "your-key-name-region-one"
    key_name_region_two = "your-key-name-region-two"
    ```

3.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

4.  **Plan the deployment:**
    ```bash
    terraform plan
    ```

5.  **Apply the configuration:**
    ```bash
    terraform apply
    ```

## Resources Created

This Terraform configuration creates the following resources:

-   Two VPCs in different AWS regions.
-   Subnets in each VPC.
-   Internet Gateways for each VPC.
-   Route tables for each VPC.
-   A VPC peering connection between the two VPCs.
-   Routes in each VPC's route table to enable traffic flow across the peering connection.
-   Security groups in each VPC to allow HTTP, SSH, and ICMP traffic.
-   An EC2 instance in each VPC with a simple web server for testing.

## Inputs

| Name                        | Description                            | Type           | Default      | Required |
|-----------------------------|----------------------------------------|----------------|--------------|:--------:|
| `profile`                   | AWS profile to use                     | `string`       | n/a          |   yes    |
| `region_one`                | First AWS region                       | `string`       | n/a          |   yes    |
| `region_two`                | Second AWS region                      | `string`       | n/a          |   yes    |
| `vpc_one_cidr`              | CIDR block for VPC in region one       | `string`       | n/a          |   yes    |
| `vpc_one_subnet_count`      | Number of subnets in VPC one           | `number`       | n/a          |   yes    |
| `vpc_one_subnet_cidrs`      | Subnet CIDR blocks for VPC one         | `list(string)` | n/a          |   yes    |
| `vpc_one_azs`               | Availability zones for VPC one subnets | `list(string)` | `[]`         |    no    |
| `vpc_one_route_table_count` | Number of route tables for VPC one     | `number`       | `1`          |    no    |
| `vpc_one_create_igw`        | Create Internet Gateway for VPC one    | `bool`         | `true`       |    no    |
| `vpc_two_cidr`              | CIDR block for VPC in region two       | `string`       | n/a          |   yes    |
| `vpc_two_subnet_count`      | Number of subnets in VPC two           | `number`       | n/a          |   yes    |
| `vpc_two_subnet_cidrs`      | Subnet CIDR blocks for VPC two         | `list(string)` | n/a          |   yes    |
| `vpc_two_azs`               | Availability zones for VPC two subnets | `list(string)` | `[]`         |    no    |
| `vpc_two_route_table_count` | Number of route tables for VPC two     | `number`       | `1`          |    no    |
| `vpc_two_create_igw`        | Create Internet Gateway for VPC two    | `bool`         | `true`       |    no    |
| `instance_type`             | EC2 instance type                      | `string`       | `"t2.micro"` |    no    |
| `key_name_region_one`       | Key pair name for region one           | `string`       | n/a          |   yes    |
| `key_name_region_two`       | Key pair name for region two           | `string`       | n/a          |   yes    |

## Outputs

| Name                          | Description                                |
|-------------------------------|--------------------------------------------|
| `vpc_one_instance_private_ip` | Private IP of VPC 1 instance               |
| `vpc_two_instance_private_ip` | Private IP of VPC 2 instance               |
| `vpc_one_instance_public_ip`  | Public IP of VPC 1 instance (if available) |
| `vpc_two_instance_public_ip`  | Public IP of VPC 2 instance (if available) |
| `test_instructions`           | Instructions to test VPC peering           |
