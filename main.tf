# --- aws-s3-53/storage.tf ---

data "aws_route53_zone" "selected" {
  name = var.domain_name
}

resource "aws_s3_bucket" "main" {
  bucket = var.domain_name
  tags   = var.tags
}

# -- Policies --
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.allow_public_get_access
}

resource "aws_s3_bucket_public_access_block" "main_public_access" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.main.id
  index_document { suffix = "index.html" }
  error_document { key = "error.html" }
}
