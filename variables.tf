# --- s3-static-website/variables.tf ---

variable "tags" {
  description = "Map of key/value pairs to tag certain created items."
  type        = map(string)
  default     = {}
}

variable "domain_name" {
  description = "Base domain name for hosted zone e.g. 'example.com'."
  type        = string
}

variable "hosted_zone_name" {
  description = "Name of hosted zone that domain_name is within."
  type        = string
}

variable "point_www_to_apex" {
  description = "Option to add a CNAME record to the WWW subdomain to point to the apex."
  default = false
}