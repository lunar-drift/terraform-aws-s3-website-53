variable "apex_domain" {
  description = "Apex domain name for the hosted zone and S3 bucket."
  type        = string
}

variable "use_www" {
  description = "Set to 1 to create a www. Route 53 alias record pointing to the CloudFront distribution."
  type        = number
  default     = 0
}

variable "cf_aliases" {
  description = "CloudFront distribution aliases (domain names)."
  type        = list(string)
}

variable "cf_restricted_locations" {
  description = "ISO 3166-1 alpha-2 country codes to blacklist from CloudFront. Empty list disables geo-restriction."
  type        = list(string)
  default     = []
}

variable "cf_allowed_methods" {
  description = "HTTP methods CloudFront forwards to the origin."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cf_cached_methods" {
  description = "HTTP methods CloudFront caches responses for."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "client_name" {
  description = "Client identifier applied as a resource tag."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Deployment environment applied as a resource tag (e.g. production, staging)."
  type        = string
  default     = "production"
}

variable "studio_role_arn" {
  description = "Optional ARN of an IAM role granted read/write/delete access to the origin bucket (e.g. a Lunar Drift Studio deployment role)."
  type        = string
  default     = null
}
