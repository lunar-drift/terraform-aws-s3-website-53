output "bucket" {
  value = aws_s3_bucket.main
}

output "policy" {
  value = data.aws_iam_policy_document.allow_public_get_access
}