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
  source      = "../../"
  apex_domain = "geotorus.com"
  use_www     = 1
  cloudfront = {
    cf_aliases                   = ["geotorus.com", "www.geotorus.com"]
    cf_geo_restriction_type      = "none"
    cf_geo_restriction_locations = []
  }
}

# Upload index.html to bucket
resource "aws_s3_object" "object" {
  bucket       = module.static-s3-website.bucket.id
  key          = "index.html"
  source       = "./index.html"
  content_type = "text/html"
}