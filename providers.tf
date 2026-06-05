terraform {
  required_version = ">= 1.8.0" # Ensures compatibility with latest OpenTofu features

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  # Note: Certain resources are only available in `us-east-1`
  region = "us-east-1" # DO NOT CHANGE
  default_tags {
    tags = {
      ManagedBy   = var.infrastructure_manager
      Environment = var.environment
    }
  }
}
