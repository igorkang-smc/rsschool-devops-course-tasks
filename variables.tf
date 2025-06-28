variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources in."
  default     = "ap-northeast-2"
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
  default     = "rsschool-tf-state-12167"
}

variable "repo_name" {
  type        = string
  description = "The GitHub repository name for OIDC trust (format: owner/repo)."
  default     = "igorkang-smc/rsschool-devops-course-tasks"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
  default     = "main-vpc"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets. If not provided, will be calculated automatically."
  default     = []
}

variable "private_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets. If not provided, will be calculated automatically."
  default     = []
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones to create subnets in. If not provided, will use available AZs in the region."
  default     = []
}

variable "bastion_allowed_cidr" {
  type        = list(string)
  description = "CIDR blocks allowed to connect to bastion host"
  default     = ["0.0.0.0/0"] # Should be restricted in production
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type for bastion/NAT and other EC2 instances"
  default     = "t3.micro"
}

variable "ec2_key_name" {
  type        = string
  description = "Name of the AWS key pair to use for EC2 instances"
  default     = "task2"
}

variable "ami_id" {
  type        = string
  description = "AMI ID to use for EC2 instances. If not set, the latest Amazon Linux 2 AMI will be used."
  default     = ""
}
