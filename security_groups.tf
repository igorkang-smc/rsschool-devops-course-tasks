# Bastion SG – inbound SSH from your IP, outbound anywhere
resource "aws_security_group" "bastion" {
  name        = "${var.project}-bastion-sg"
  description = "Allow SSH from admin IP to bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.my_ip]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private tier SG – allow SSH only from bastion SG
resource "aws_security_group" "private" {
  name        = "${var.project}-private-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from bastion"
    protocol         = "tcp"
    from_port        = 22
    to_port          = 22
    security_groups  = [aws_security_group.bastion.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}