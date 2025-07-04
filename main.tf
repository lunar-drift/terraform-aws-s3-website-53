# Get Zone ID for Certificate Use and Adding CloudFront Alias Record
data "aws_route53_zone" "selected" {
  name = var.apex_domain
}

# Create Bucket and Attach necessary Permissions.
module "s3_bucket" {
  source      = "./bucket"
  bucket_name = var.apex_domain
}

# Create Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = module.s3_bucket.bucket.id
  index_document { suffix = "index.html" }
  error_document { key = "error.html" }

}

# Create SSL Certificate
resource "aws_acm_certificate" "main" {
  domain_name               = var.apex_domain
  subject_alternative_names = ["*.${var.apex_domain}"]
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
  zone_id         = data.aws_route53_zone.selected.zone_id
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
  aliases             = var.cloudfront.cf_aliases
  # Allowable response codes https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/custom-error-pages-response-code.html
  # These are errors anyway and need to be seen in production.
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/error.html"
  }


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
    acm_certificate_arn = aws_acm_certificate.main.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront.cf_geo_restriction_type
      locations        = var.cloudfront.cf_geo_restriction_locations
    }
  }
}

# Point web traffic from apex_domain towards the CF Distribution.
resource "aws_route53_record" "apex_alias" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.apex_domain
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

# Point HTTP Traffic from www subdomain towards the CF Distribution.
resource "aws_route53_record" "www_alias" {
  count   = var.use_www
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www.${var.apex_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
  depends_on = [
    aws_cloudfront_distribution.main
  ]
}