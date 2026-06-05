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
  source     = "../../"
  web_domain = "geotorus.com."
  cf_aliases = ["geotorus.com", "www.geotorus.com"]
}


resource "aws_s3_object" "object" {
  bucket       = module.static-s3-website.origin_bucket_name
  key          = "index.html"
  source       = "./index.html"
  content_type = "text/html"
}
