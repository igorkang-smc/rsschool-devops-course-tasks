# Generate a 4096‑bit RSA private key locally
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload the public half to AWS as an EC2 key pair
resource "aws_key_pair" "bastion" {
  key_name   = "${var.project}-key"   # will show up in the console
  public_key = tls_private_key.bastion.public_key_openssh
}