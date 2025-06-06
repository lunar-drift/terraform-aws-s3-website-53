variable "apex_domain" {
  description = "Apex Domain for web endpoint."
  type        = string
}

variable "www_resolves_to_apex" {
  description = "Option to add a CNAME record to the WWW subdomain to point to the apex."
  type        = number
  default     = 0
}