# EC2 instance NAT+Bastion
resource "aws_instance" "nat_bastion" {
  ami                         = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true
  key_name                    = var.ec2_key_name
  source_dest_check           = false
  user_data                   = file("${path.module}/user_data_nat.sh")
  tags                        = { Name = "${var.vpc_name}-nat-bastion" }
}

# Data source for AMI

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
