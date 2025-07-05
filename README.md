# AWS VPC Infrastructure with Bastion Host and NAT Instance

This Terraform project creates a secure AWS VPC infrastructure with public and private subnets, a bastion host for secure access, and a NAT instance for outbound connectivity from private subnets.

## Infrastructure Components

- **VPC**: A Virtual Private Cloud with CIDR block 10.0.0.0/16
- **Public Subnets**: 2 public subnets in different availability zones
- **Private Subnets**: 2 private subnets in different availability zones
- **Internet Gateway**: Allows communication between instances in the VPC and the internet
- **NAT Instance**: Allows instances in private subnets to access the internet
- **Bastion Host**: Secure entry point for SSH access to instances in private subnets. The same physical instance as NAT one
- **Security Groups**: Configured for private and public instances, bastion host + NAT instance

## Network Connectivity

- Instances in all subnets can communicate with each other
- Instances in public subnets have direct internet access
- Instances in private subnets can access the internet through the NAT instance
- External access to private instances is only possible through the bastion host

## Prerequisites

- AWS account with appropriate permissions
- Terraform installed (version >= 1.0.0)
- SSH key pair created in AWS

## Usage

1. Clone this repository
2. Update the `terraform.tfvars` file with your specific values. Use `terraform.tfvars` as reference:



3. Initialize Terraform:

```bash
terraform init
```

4. Apply the Terraform configuration:

```bash
terraform apply
```

5. After successful deployment, you'll see outputs including the bastion host's public IP address.

## Accessing Private Instances

To access instances in private subnets:

1. SSH to the bastion host:

```bash
ssh -i your-key.pem ec2-user@<bastion-public-ip>
```

2. From the bastion host, SSH to the private instance:

```bash
ssh -i your-key.pem ec2-user@<private-instance-ip>
```

## Security Considerations

- The bastion host security group allows SSH access only
- Private instances only allow SSH access from the bastion host
- The NAT instance allows outbound traffic from private subnets

## Cost Optimization

This implementation uses a NAT instance instead of a NAT Gateway to reduce costs.

## Cleanup

To destroy all resources created by this Terraform configuration:

```bash
terraform destroy
```

## GitHub Actions Required Secrets

To enable CI/CD with GitHub Actions, you must configure the following repository secrets:

- `EXTRA_BUCKET` — S3 bucket name for storing Terraform artifacts (not the state bucket)
- `TERRAFORM_STATE_BUCKET` — S3 bucket name for storing Terraform state
- `AWS_ACCOUNT_ID` — Your AWS account ID
- `EC2_KEY_NAME` — Name of the AWS EC2 key pair to use for SSH
- `ALLOWED_CIDR` — CIDR block allowed to access the bastion host (e.g., `1.2.3.4/32`)

All secrets can be set in your repository settings under **Settings → Secrets and variables → Actions**.