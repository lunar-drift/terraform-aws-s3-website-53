data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.main.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }

  dynamic "statement" {
    for_each = var.studio_role_arn != null ? [1] : []
    content {
      sid    = "AllowStudioAccess"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = [var.studio_role_arn]
      }

      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
      ]

      resources = [
        aws_s3_bucket.main.arn,
        "${aws_s3_bucket.main.arn}/*",
      ]
    }
  }
}
