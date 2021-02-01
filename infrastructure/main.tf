provider "aws" {
  region  = "eu-west-3"
  profile = "cinema"
}

terraform {
  backend "s3" {
    bucket = "nc-app-cinema-tf-state"
    key    = "app-cinema.tfstate"
    region = "eu-west-3"
    # encrypt = true
  }
}

locals {
  prefix = "${var.prefix}-${terraform.workspace}"
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project
    ManagedBy   = "Terraform"
    Owner       = "Nicolas Corbet"
  }
}