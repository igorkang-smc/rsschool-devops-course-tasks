variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the subnets will be created. This should be provided to associate the subnets with the correct VPC."
}

variable "cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks for the subnets. Each CIDR block should correspond to an availability zone in the same order."
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones to create subnets in. The number of AZs should match the number of CIDR blocks."

  validation {
    condition     = length(var.cidr_blocks) == length(var.azs)
    error_message = "The number of CIDR blocks must match the number of availability zones."
  }
}

variable "route_table_id" {
  type        = string
  description = "ID of the route table to associate with the subnets. If not provided, a new route table will be created."
}

variable "is_public" {
  type    = bool
  default = false
}

variable "vpc_name" {
  type        = string
  description = "Name tag for the VPC"
}
