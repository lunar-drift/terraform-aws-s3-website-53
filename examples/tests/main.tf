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

variable "apex_domain" {}
variable "www_resolves_to_apex" { default = 0 }

module "test-static-s3-website" {
  source      = "../../"
  apex_domain = var.apex_domain


  # Booleans
  www_resolves_to_apex = var.www_resolves_to_apex
}