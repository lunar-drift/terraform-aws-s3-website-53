# Changelog

## Version 1.0.0
- **Breaking**: Replaced public S3 origin with a fully private bucket + CloudFront Origin Access Control (OAC, sigv4 signing)
- **Breaking**: Flattened the `cloudfront` variable object into individual top-level variables (`cf_aliases`, `cf_restricted_locations`, `cf_allowed_methods`, `cf_cached_methods`)
- **Breaking**: Removed `bucket_policy` and `bucket_website_configuration` outputs; removed the `bucket/` submodule
- **Breaking**: Renamed output `route53_record` → `route53_record_apex`
- Switched CloudFront cache policy to Managed-CachingOptimized (`658327ea-f89d-4fab-a63d-7e88639e58f6`)
- Updated minimum TLS protocol version to `TLSv1.2_2021`
- Added `price_class = "PriceClass_All"` to CloudFront distribution
- Added `client_name` and `environment` variables for resource tagging
- Added optional `studio_role_arn` variable for cross-account read/write/delete access to the origin bucket
- Added `cdn_domain_name` and `cdn_distribution_id` convenience outputs
- Added `providers.tf` with explicit required provider constraints
- Added `data.tf` with bucket IAM policy document (CloudFront service principal + optional studio role)

## Version 0.2.0
- Changed Input variables
- Added www functionality
