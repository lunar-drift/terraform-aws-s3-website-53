data "aws_route53_zone" "selected" {
  name = var.apex_domain
}

resource "aws_s3_bucket" "main" {
  bucket = var.apex_domain

  tags = {
    Client      = var.client_name
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "main" {
  bucket     = aws_s3_bucket.main.id
  policy     = data.aws_iam_policy_document.bucket_policy.json
  depends_on = [aws_s3_bucket_public_access_block.main]
}

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = var.apex_domain
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_acm_certificate" "main" {
  domain_name               = var.apex_domain
  subject_alternative_names = ["*.${var.apex_domain}"]
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

resource "aws_cloudfront_distribution" "main" {
  depends_on          = [aws_acm_certificate_validation.main]
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = var.cf_aliases
  price_class         = "PriceClass_All"

  tags = {
    Client      = var.client_name
    ManagedBy   = "terraform"
    Environment = var.environment
  }

  origin {
    domain_name              = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id                = var.apex_domain
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = var.cf_allowed_methods
    cached_methods         = var.cf_cached_methods
    target_origin_id       = var.apex_domain
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
  name    = var.apex_domain
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
  name    = "www.${var.apex_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}
