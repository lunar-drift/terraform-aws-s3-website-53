# MIT Lunar Drift 2025
# Components:
# 0. Locals
# 1. Origin Bucket
# 2. DNS Zone
# 3. ACM Certificate
# 4. CloudFront Distribution
# 5. WAF Shield (if using fixed rate plan)

# ======== 0. Locals ========
locals {
  web_domain = trimsuffix(var.web_domain, ".")
  origin_id = "${var.web_domain}-${var.infrastructure_manager}"

  origin_bucket_name = local.web_domain
  cf_allowed_domains = [local.web_domain]
}

# ======== 1. Origin Bucket ========
resource "aws_s3_bucket" "origin" {
  bucket = local.origin_bucket_name
}
resource "aws_s3_bucket_versioning" "origin" {
  bucket = aws_s3_bucket.origin.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_public_access_block" "origin" {
  bucket                  = aws_s3_bucket.origin.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_policy" "origin" {
  depends_on = [aws_s3_bucket_public_access_block.origin] # required for errorless creation.

  bucket = aws_s3_bucket.origin.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

# ======== 2. DNS Zone ========
data "aws_route53_zone" "selected" {
  name = local.web_domain
}

# ======== 3. ACM Certificate ========
resource "aws_acm_certificate" "main" {
  domain_name               = local.web_domain  # TODO first item in list from locals
  subject_alternative_names = ["*.${local.web_domain}"]   # TODO wildcard certificate as default.
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  # Keep these records in your DNS Zone for auto-renewal of certificate.
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

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "${local.origin_id}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  depends_on          = [aws_acm_certificate_validation.main]
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = var.cf_aliases
  price_class         = "PriceClass_All"

  origin {
    domain_name              = aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = var.cf_allowed_methods
    cached_methods         = var.cf_cached_methods
    target_origin_id       = local.origin_id
  }

  restrictions {
    geo_restriction {
      restriction_type = length(var.cf_restricted_locations) > 0 ? "blacklist" : "none"
      locations        = var.cf_restricted_locations
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.main.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  custom_error_response {
    error_caching_min_ttl = 86400
    error_code            = 404
    response_code         = 200
    response_page_path    = "/error.html"
  }
}

resource "aws_route53_record" "apex_alias" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.web_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_alias" {
  count   = var.use_www
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www.${local.web_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}
