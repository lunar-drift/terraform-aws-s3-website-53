terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "static-s3-website" {
  source = "../../"
  # Required inputs
  apex_domain = "geotorus.com"
  use_www     = 1
  cloudfront = {
    cf_aliases                   = ["geotorus.com", "www.geotorus.com"]
    cf_geo_restriction_type      = "none"
    cf_geo_restriction_locations = []
  }
}
