# This module creates EC2 instances in specified subnets with optional NAT server functionality.
# It supports both public and private subnets, with security groups configured for SSH, HTTP, and HTTPS access.

# Data source to get the latest Amazon Linux 2 AMI
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

# EC2 instances
resource "aws_instance" "ec2" {
  count                       = length(var.subnet_ids)
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.subnet_ids[count.index]
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.is_public
  key_name                    = var.ec2_key_name

  user_data = base64encode(templatefile("${path.module}/user_data_default.sh", {
    instance_name = "${var.name_prefix}-${count.index + 1}"
    instance_type = var.is_public ? "public" : "private"
  }))

  tags = {
    Name = "${var.name_prefix}-${count.index + 1}"
    Type = var.is_public ? "public" : "private"
  }

  lifecycle {
    create_before_destroy = true
  }
}
