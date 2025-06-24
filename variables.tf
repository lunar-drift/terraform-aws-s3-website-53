variable "apex_domain" {
  description = "Apex Domain for web endpoint."
  type        = string
  default     = "value"
}

variable "cloudfront" {
  type = object({
    cf_aliases                   = list(any) #string
    cf_geo_restriction_locations = list(string)
    cf_geo_restriction_type      = string
  })
  # validation: cf_aliases contain legal domain and subdomain names.
  #             cf_geo_restriction_locations values are legal countries, or is empty if none.
  #             cf_geo_restriction_type is whitelist, blacklist or none.
}

variable "use_www" {
  description = "Option that creates a DNS record that points the www domain to the CloudFront Distribution."
  type        = number
  default     = 0
  # validation: www.apex is within the cloudfront.cf_aliases list.
}