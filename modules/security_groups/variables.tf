variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC for inter-subnet communication"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "bastion_allowed_cidr" {
  description = "CIDR blocks allowed to connect to bastion host (SSH)"
  type        = list(string)
}
