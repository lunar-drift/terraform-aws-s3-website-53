# --- aws-s3-53/main.tf ---

module "dns" {
  source          = "spacelift.io/gspider8/dns/aws"
  version         = "0.0.14"
  domain_name     = var.domain_name
  create_r53_zone = var._create_r53_zone
  dns_records = {
    main = {
      test = {
        name    = var.domain_name
        type    = "TXT"
        ttl     = 60
        records = ["test content"]
      }
    }
  }
}

# data "aws_route53_zone" "main" {
#   name = var.domain_name
# }
#
# module "s3_bucket" {
#   source      = "./storages"
#   # Creates bucket and attaches necessary permissions
#   bucket_name = var.domain_name
#   tags        = var.tags
# }
#
# resource "aws_s3_bucket_website_configuration" "hosting" {
#   bucket = module.s3_bucket.bucket.id
#   index_document { suffix = "index.html" }
#   error_document { key = "error.html" }
# }
#
# resource "aws_acm_certificate" "cert" {
#   domain_name       = data.aws_route53_zone.main.name
#   validation_method = "DNS"
#   lifecycle {
#     create_before_destroy = true
#   }
# }
#
# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }
#
#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.main.zone_id
# }
#
# resource "aws_cloudfront_distribution" "main" {
#   depends_on          = [aws_acm_certificate.cert]
#   default_root_object = "index.html"
#   is_ipv6_enabled     = true
#   enabled             = true
#   aliases             = [var.domain_name] # geotorus.org
#   tags                = var.tags
#
#   origin {
#     domain_name = module.s3_bucket.bucket.bucket_regional_domain_name
#     origin_id   = module.s3_bucket.bucket.bucket_regional_domain_name
#   }
#
#   default_cache_behavior {
#     cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
#     viewer_protocol_policy = "redirect-to-https"
#     compress               = true
#     allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods         = ["GET", "HEAD"]
#     target_origin_id       = module.s3_bucket.bucket.bucket_regional_domain_name
#   }
#
#   viewer_certificate {
#     acm_certificate_arn = aws_acm_certificate.cert.arn
#     ssl_support_method  = "sni-only"
#   }
#
#   restrictions {
#     geo_restriction {
#       restriction_type = "whitelist"
#       locations        = ["US", "CA", "GB", "DE"]
#     }
#   }
# }
#
# resource "aws_route53_record" "alias" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = var.domain_name
#   type    = "A"
#
#   alias {
#     name                   = aws_cloudfront_distribution.main.domain_name
#     zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
#     evaluate_target_health = true
#   }
#   depends_on = [
#     aws_cloudfront_distribution.main
#   ]
# }