output "route53_zone" {
  description = "Route 53 hosted zone data source."
  value       = data.aws_route53_zone.selected
}

output "bucket" {
  description = "S3 origin bucket."
  value       = aws_s3_bucket.main
}

output "acm_certificate" {
  description = "ACM certificate."
  value       = aws_acm_certificate.main
}

output "acm_certificate_validation" {
  description = "ACM certificate validation resource."
  value       = aws_acm_certificate_validation.main
}

output "cloudfront_distribution" {
  description = "CloudFront distribution."
  value       = aws_cloudfront_distribution.main
}

output "cdn_domain_name" {
  description = "CloudFront distribution domain name (for Route 53 ALIAS records)."
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cdn_distribution_id" {
  description = "CloudFront distribution ID."
  value       = aws_cloudfront_distribution.main.id
}

output "route53_record_apex" {
  description = "Route 53 apex alias record."
  value       = aws_route53_record.apex_alias
}
