terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "static-s3-website" {
  source            = "../../"
  # Required inputs
  apex_domain       = "webdatabasesolutions.com"
  point_www_to_apex = true
}
