output "vpc_one_instance_private_ip" {
  description = "Private IP of VPC 1 instance"
  value       = aws_instance.vpc_one_instance.private_ip
}

output "vpc_two_instance_private_ip" {
  description = "Private IP of VPC 2 instance"
  value       = aws_instance.vpc_two_instance.private_ip
}

output "vpc_one_instance_public_ip" {
  description = "Public IP of VPC 1 instance (if available)"
  value       = aws_instance.vpc_one_instance.public_ip
}

output "vpc_two_instance_public_ip" {
  description = "Public IP of VPC 2 instance (if available)"
  value       = aws_instance.vpc_two_instance.public_ip
}

output "test_instructions" {
  description = "Instructions to test VPC peering"
  value = <<-EOT
    To test VPC peering:
    1. SSH into VPC 1 instance: ssh -i your-key.pem ec2-user@${aws_instance.vpc_one_instance.public_ip}
    2. Test connection to VPC 2: curl http://${aws_instance.vpc_two_instance.private_ip}
    3. SSH into VPC 2 instance: ssh -i your-key.pem ec2-user@${aws_instance.vpc_two_instance.public_ip}
    4. Test connection to VPC 1: curl http://${aws_instance.vpc_one_instance.private_ip}
  EOT
}