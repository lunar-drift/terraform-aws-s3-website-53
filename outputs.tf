output "route53_zone" {
  value = data.aws_route53_zone.selected
}

output "bucket" {
  value = module.s3_bucket.bucket
}

output "bucket_policy" {
  value = module.s3_bucket.policy
}

output "bucket_website_configuration" {
  value = aws_s3_bucket_website_configuration.hosting
}

output "acm_certificate" {
  value = aws_acm_certificate.main
}

output "acm_certificate_validation" {
  value = aws_acm_certificate_validation.main
}

output "cloudfront_distribution" {
  value = aws_cloudfront_distribution.main
}

output "route53_record" {
  value = aws_route53_record.alias
}
