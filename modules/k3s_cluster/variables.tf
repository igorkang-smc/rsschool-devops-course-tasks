variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for the k3s server and agent (expect at least 2)."
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ec2_key_name" {
  type = string
}

variable "ami_id" {
  type    = string
  default = ""
  description = "Custom AMI to use for the nodes. Leave empty to use the latest Amazon Linux 2."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups to attach to the nodes. Must allow traffic on 6443 within the VPC."
}

variable "vpc_cidr" {
  type = string
}
