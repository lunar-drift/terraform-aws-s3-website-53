# --- s3-static-website/variables.tf ---

variable "tags" {
  description = "Map of key/value pairs to tag certain created items."
  type        = map(string)
  default     = {}
}

variable "www_resolves_to_apex" {
  description = "Option to add a CNAME record to the WWW subdomain to point to the apex."
  type        = number
  default     = 0
}

variable "apex_domain" {
  description = "Apex Domain for web endpoint."
  type        = string
}

