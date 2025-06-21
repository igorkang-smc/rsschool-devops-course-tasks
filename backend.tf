
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.68"
    }
  }
  backend "s3" {
    bucket  = "rsschool-tf-state-12167"
    key     = "global/s3/terraform.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
  }
}
provider "aws" {
  region = var.region  # ← maybe change
}