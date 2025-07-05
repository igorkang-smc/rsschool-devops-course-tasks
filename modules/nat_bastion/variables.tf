variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet for NAT+Bastion instance"
  type        = string
}

variable "bastion_allowed_cidr" {
  description = "CIDR blocks allowed to connect to bastion host (SSH)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ec2_key_name" {
  description = "Name of the key pair to use for SSH access"
  type        = string
  default = "task2"
}

variable "ami_id" {
  description = "AMI ID to use for the instance (if not specified, latest Amazon Linux 2 will be used)"
  type        = string
  default     = ""
}

variable "ec2_instance_type" {
  description = "Instance type for NAT+Bastion instance"
  type        = string
  default     = "t3.micro"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the NAT+Bastion instance"
  type        = list(string)
}