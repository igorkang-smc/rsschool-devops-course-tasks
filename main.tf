module "s3_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = var.bucket_name
}

module "iam_github_actions" {
  source    = "./modules/iam_github_actions"
  repo_name = var.repo_name
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
}

module "public_subnets" {
  source         = "./modules/subnets"
  vpc_id         = module.vpc.vpc_id
  vpc_name       = module.vpc.vpc_name
  cidr_blocks    = local.public_subnets
  azs            = local.availability_zones
  is_public      = true
  route_table_id = module.routes.public_route_table_id
}

module "private_subnets" {
  source         = "./modules/subnets"
  vpc_id         = module.vpc.vpc_id
  vpc_name       = module.vpc.vpc_name
  cidr_blocks    = local.private_subnets
  azs            = local.availability_zones
  is_public      = false
  route_table_id = module.routes.private_route_table_id
}

module "security_groups" {
  source               = "./modules/security_groups"
  vpc_id               = module.vpc.vpc_id
  vpc_name             = module.vpc.vpc_name
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = local.private_subnets
  bastion_allowed_cidr = var.bastion_allowed_cidr
}

module "nat_bastion" {
  source               = "./modules/nat_bastion"
  vpc_id               = module.vpc.vpc_id
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  public_subnet_id     = module.public_subnets.subnet_ids[0]
  bastion_allowed_cidr = var.bastion_allowed_cidr
  ec2_key_name         = var.ec2_key_name
  ami_id               = var.ami_id
  ec2_instance_type    = var.ec2_instance_type
  security_group_ids   = [module.security_groups.nat_sg_id, module.security_groups.bastion_sg_id]
}

module "routes" {
  source              = "./modules/routes"
  vpc_name            = module.vpc.vpc_name
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.vpc.internet_gateway_id
  nat_instance_id     = module.nat_bastion.nat_network_interface_id
}

module "ec2_public" {
  source             = "./modules/ec2"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = [module.public_subnets.subnet_ids[1]]
  ec2_instance_type  = var.ec2_instance_type
  ec2_key_name       = var.ec2_key_name
  name_prefix        = "public-ec2"
  is_public          = true
  vpc_cidr           = var.vpc_cidr
  security_group_ids = [module.security_groups.public_sg_id]
}

module "ec2_private" {
  source             = "./modules/ec2"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.private_subnets.subnet_ids
  ec2_instance_type  = var.ec2_instance_type
  ec2_key_name       = var.ec2_key_name
  name_prefix        = "private-ec2"
  is_public          = false
  vpc_cidr           = var.vpc_cidr
  security_group_ids = [module.security_groups.private_sg_id]
}

# Data source to get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Local values for computed subnets and AZs
locals {
  # Use provided AZs or get first 2 available ones
  availability_zones = length(var.azs) > 0 ? var.azs : slice(data.aws_availability_zones.available.names, 0, 2)
  # Calculate subnet CIDR blocks if not provided
  public_subnets = length(var.public_subnets) > 0 ? var.public_subnets : [
    for i in range(length(local.availability_zones)) :
    cidrsubnet(var.vpc_cidr, 8, i * 2)
  ]

  private_subnets = length(var.private_subnets) > 0 ? var.private_subnets : [
    for i in range(length(local.availability_zones)) :
    cidrsubnet(var.vpc_cidr, 8, i * 2 + 1)
  ]
}
