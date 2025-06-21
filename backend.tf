
terraform {
  required_version = ">= 1.6"

  backend "s3" {
    bucket         = "rsschool-tf-state-12167"
    key            = "global/s3/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}