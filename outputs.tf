output "github_actions_role_arn" {
  value       = module.iam_github_actions.github_actions_role_arn
  description = "ARN of the IAM role for GitHub Actions."
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the VPC"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "CIDR block of the VPC"
}

output "internet_gateway_id" {
  value       = module.vpc.internet_gateway_id
  description = "ID of the Internet Gateway"
}

output "public_route_table_id" {
  value       = module.routes.public_route_table_id
  description = "ID of the public route table"
}

output "private_route_table_id" {
  value       = module.routes.private_route_table_id
  description = "ID of the private route table"
}

output "public_subnet_ids" {
  value       = module.public_subnets.subnet_ids
  description = "IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = module.private_subnets.subnet_ids
  description = "IDs of the private subnets"
}

output "ec2_instance_ids" {
  value       = module.ec2_public.instance_ids
  description = "IDs of the EC2 instances in public subnets"
}

output "ec2_public_ips" {
  value       = module.ec2_public.public_ips
  description = "Public IP addresses of the EC2 instances"
}

output "ec2_private_ips" {
  value       = module.ec2_public.private_ips
  description = "Private IP addresses of the EC2 instances"
}

output "ec2_public_dns" {
  value       = module.ec2_public.public_dns
  description = "Public DNS names of the EC2 instances"
}

output "ec2_instance_details" {
  value       = module.ec2_public.instance_details
  description = "Detailed information about all EC2 instances"
}

output "ec2_private_instance_ids" {
  value       = module.ec2_private.instance_ids
  description = "IDs of the EC2 instances in private subnets"
}

output "ec2_private_instance_private_ips" {
  value       = module.ec2_private.private_ips
  description = "Private IP addresses of the EC2 instances in private subnets"
}

output "ec2_private_instance_details" {
  value       = module.ec2_private.instance_details
  description = "Detailed information about all EC2 instances in private subnets"
}

output "nat_instance_id" {
  value       = module.nat_bastion.nat_instance_id
  description = "ID of the NAT server instance"
}

output "nat_instance_public_ip" {
  value       = module.nat_bastion.nat_instance_public_ip
  description = "Public IP address of the NAT server instance"
}

output "calculated_availability_zones" {
  value       = local.availability_zones
  description = "Availability zones used for subnets"
}

output "calculated_public_subnets" {
  value       = local.public_subnets
  description = "CIDR blocks for public subnets (calculated or provided)"
}

output "calculated_private_subnets" {
  value       = local.private_subnets
  description = "CIDR blocks for private subnets (calculated or provided)"
}
