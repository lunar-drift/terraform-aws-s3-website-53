output "cdn_distribution_id" {
  description = "CloudFront distribution ID."
  value       = aws_cloudfront_distribution.main.id
}

output "acm_certificate_validation" {
  description = "ACM certificate validation resource."
  value       = aws_acm_certificate_validation.main
}

output "cdn_domain_name" {
  description = "CloudFront distribution domain name (for CNAME or ALIAS records)."
  value       = aws_cloudfront_distribution.main.domain_name
}
output "origin_bucket_name" {
  value = aws_s3_bucket.origin.bucket
}
