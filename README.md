# Task 2 – Basic Infrastructure Configuration

This stack bootstraps a **Kubernetes‑ready network** in AWS using Terraform 1.6 + AWS provider 5.x.

## What you get

| Layer | Resources |
|-------|-----------|
| Networking | VPC, 2 × public + 2 × private subnets in separate AZs, IGW, NAT (GW or EC2), route tables, SGs & NACL |
| Security | Dedicated SGs, optional NACL for private tier |
| Access | Bastion host in first public subnet with Elastic IP |
| CI/CD | _Optional_ GitHub Actions workflow that runs `terraform fmt`, `terraform init`, `terraform validate`, and `terraform plan` on every PR |

## Usage

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # edit values
terraform init
terraform plan -out planfile
terraform apply planfile