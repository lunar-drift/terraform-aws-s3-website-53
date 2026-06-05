variable "web_domain" {
  description = "Apex domain name for the hosted zone and S3 bucket."
  type        = string
  # TODO add validation of format *.*.
}

variable "cloudfront_configuration" {
  description = "Object that defines configuration for CloudFront Distribution."
  default = {}
  # TODO Configure
  #  is_cloudfront_fixed_rate_plan
  #  cached_methods
  #  allowed_methods
  #  restricted_locations
  #  allowed_domains
  #  origin_bucket_name
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



variable "dns_configuration" {
  description = "Object that defines configuration for DNS Records"
  default = {}
  # TODO
  #  use_route_53
  #  add addt'l records
}

variable "certificate_configuration" {
  description = "Object that defines configuration for ACM Certificate Resources"
  default = {}
}

variable "environment" {
  description = "Deployment environment applied as a resource tag (e.g. production, staging)."
  type        = string
  default     = "production"
}

variable "infrastructure_manager" {
  description = "Name of service that manages the given infrastructure."
  # TODO add to global aws tags.
  default = "tofu-aws-static-website"
}

variable "content_manager_arn" {
  # TODO remove null option with logic associated in data.tf
  description = "ARN of an IAM role granted object write/delete access to the origin bucket (e.g. a Lunar Drift Studio deployment role)."
  type        = string
  default     = null
}

variable "use_www" {
  description = "Set to 1 to create a www. Route 53 alias record pointing to the CloudFront distribution."
  type        = number
  default     = 0
}