terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "domain_name" {}
variable "hosted_zone_name" {}

module "test-static-s3-website" {
  source           = "../../"
  domain_name      = var.domain_name
  hosted_zone_name = var.hosted_zone_name
}