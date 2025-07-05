variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to associate with route tables"
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID for public route table"
  type        = string
}

variable "nat_instance_id" {
  description = "NAT instance or network interface ID for private route table"
  type        = string
}