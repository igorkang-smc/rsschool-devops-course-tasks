### ― NAT GATEWAY ― (default, simpler)
resource "aws_eip" "nat" {
  count  = var.enable_nat_instance ? 0 : 1
  domain = "vpc"
  tags = { Name = "${var.project}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat_instance ? 0 : 1
  allocation_id = one(aws_eip.nat[*].id)
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "${var.project}-nat-gw" }
}

### ― NAT INSTANCE ― (set enable_nat_instance=true)
data "aws_ami" "amzn2_nat" {
  count       = var.enable_nat_instance ? 1 : 0
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "nat_instance" {
  count               = var.enable_nat_instance ? 1 : 0
  ami                 = one(data.aws_ami.amzn2_nat[*].id)
  instance_type       = "t3.micro"
  subnet_id           = aws_subnet.public[0].id
  key_name            = var.key_pair_name
  source_dest_check   = false
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.bastion.id]  # reuse SG to limit ssh if desired

  user_data = <<-EOF
              #!/bin/bash
              set -eux
              sysctl -w net.ipv4.ip_forward=1
              yum -y install iptables-services
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              service iptables save
              EOF

  tags = { Name = "${var.project}-nat-instance" }
}