# k3s cluster with one server (control-plane) node and one agent (worker) node
# Both nodes live in private subnets and are reachable through the bastion host.

terraform {
  required_version = ">= 1.0"
}

# Use latest AL2 AMI if custom AMI not provided
locals {
  ami_to_use = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
}

# Latest Amazon Linux 2
data "aws_ami" "amazon_linux" {
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

# Random token shared between server and agent
resource "random_password" "cluster_token" {
  length  = 20
  special = false
}

# Pick first two subnets for server & agent
locals {
  server_subnet = element(var.subnet_ids, 0)
  agent_subnet  = element(var.subnet_ids, 1)
}

# k3s server (control-plane)
resource "aws_instance" "k3s_server" {
  ami                         = local.ami_to_use
  instance_type               = var.ec2_instance_type
  subnet_id                   = local.server_subnet
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.ec2_key_name
  associate_public_ip_address = false

  user_data = templatefile("${path.module}/user_data_server.sh", {
    cluster_token = random_password.cluster_token.result
  })

  tags = {
    Name = "k3s-server"
    Role = "master"
  }
}

# k3s agent (worker) – joins the cluster created by the server
resource "aws_instance" "k3s_agent" {
  ami                         = local.ami_to_use
  instance_type               = var.ec2_instance_type
  subnet_id                   = local.agent_subnet
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.ec2_key_name
  associate_public_ip_address = false

  user_data = templatefile("${path.module}/user_data_agent.sh", {
    cluster_token     = random_password.cluster_token.result,
    server_private_ip = aws_instance.k3s_server.private_ip
  })

  tags = {
    Name = "k3s-agent"
    Role = "worker"
  }

  depends_on = [aws_instance.k3s_server]
}
