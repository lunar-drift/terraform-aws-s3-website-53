# -- s3-website-53.policies ---

data "aws_iam_policy_document" "allow_public_get_access" {
  # open to everyone or else pages won't load on the web
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.main.arn}/*",
    ]
  }
}