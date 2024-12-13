# --- s3-static-website/main.tf ---

# Get Domain Registry and Put records.
module "dns" {
  source  = "spacelift.io/gspider8/dns/aws"
  version = "0.0.14"

  domain_name     = var.domain_name
  create_r53_zone = var._create_r53_zone
  tags            = var.tags
  dns_records     = var.dns_records
}

# Create Bucket and Attache necessary Permissions.
module "s3_bucket" {
  source      = "./storages"
  bucket_name = var.domain_name
  tags        = var.tags
}

# Create Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = module.s3_bucket.bucket.id
  index_document { suffix = "index.html" }
  error_document { key = "error.html" }
}

# Create SSL Certificate
resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# Validate Ownership of Domain through DNS
resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = module.dns.route53_zone.zone_id
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}

# Create a CloudFront Distribution.
resource "aws_cloudfront_distribution" "main" {
  depends_on          = [aws_acm_certificate_validation.main]
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  enabled             = true
  aliases             = [var.domain_name] # geotorus.org
  tags                = var.tags

  origin {
    domain_name = module.s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = module.s3_bucket.bucket.bucket_regional_domain_name
  }

  default_cache_behavior {
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = module.s3_bucket.bucket.bucket_regional_domain_name
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }
}

# Point HTTP Traffic towards the CF Distribution.
resource "aws_route53_record" "alias" {
  zone_id = module.dns.route53_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }
  depends_on = [
    aws_cloudfront_distribution.main
  ]
}