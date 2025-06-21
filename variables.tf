variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project" {
  description = "Prefix for all resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "azs" {
  description = "AZs to use (leave empty to pick first two automatically)"
  type        = list(string)
  default     = []
}

variable "enable_nat_instance" {
  description = "Use cheaper NAT EC2 instance instead of NAT Gateway"
  type        = bool
  default     = false
}

variable "my_ip" {
  description = "Source IP/CIDR allowed to SSH into the bastion host"
  type        = string
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair for SSH access"
  type        = string
  default     = "rsschool-devops-task2-key"
}
variable "bucket_name" {
  type    = string
  default = "rsschool-tf-state-12167"
}