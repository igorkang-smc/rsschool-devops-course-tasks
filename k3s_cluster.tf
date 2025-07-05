module "k3s_cluster" {
  source = "./modules/k3s_cluster"

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.private_subnets.subnet_ids
  ec2_instance_type  = var.ec2_instance_type
  ec2_key_name       = var.ec2_key_name
  ami_id             = var.ami_id
  security_group_ids = [module.security_groups.private_sg_id]
  vpc_cidr           = var.vpc_cidr
}
