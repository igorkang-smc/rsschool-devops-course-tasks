data "aws_availability_zones" "available" {}

locals {
  azs = length(var.azs) > 0 ? var.azs : slice(data.aws_availability_zones.available.names, 0, 2)
}