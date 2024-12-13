# --- aws-s3-53/variables.tf ---

variable "tags" {
  description = "Map of key/value pairs to tag certain created items."
  type        = map(string)
  default = {
    Terraform = "True"
  }
}

variable "domain_name" {
  description = "Base domain name for hosted zone e.g. 'example.com'."
  type        = string
}

variable "dns_records" {
  description = "For each record in main, include name, type, ttl, & records"
  type        = map(any)
}

# Phase out
variable "_create_r53_zone" {
  description = "Used in testing to create r53 zones"
  default     = false
  type        = bool
}