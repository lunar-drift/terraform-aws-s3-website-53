# S3 Static Website w/SSL
A terraform module to provide a DNS configuration with Route 53, a bucket to store files in,
an SSL certificate managed by ACM, and a cloudfront distribution.

Public Repo: https://github.com/lunar-drift/terraform-aws-s3-website-53

### Requirements
- us-east 1 or else cloudfront / certificate / connect will not work
- Route 53 Zone already created

### Variables
#### Module Input Variables
- `domain_name` - Base domain name for hosted zone e.g. 'example.com'.
- `hosted_zone_name` - Name of hosted zone that `domain_name` is within.
- `tags` - Optional. Map of key/value pairs to tag certain created items.

### Usage
```terraform
module "s3_website" {
  source  = "spacelift.io/gspider8/s3-website-53/aws"
  version = "0.1.14"

  hosted_zone_name = "example.com"
  domain_name      = "example.com"
}
```
### Outputs
- `route_53_zone` - DNS Zone Map
- `bucket` - Bucket Map
- `bucket_policy` - Bucket Policy Map
- `bucket_website_configuration` - Bucket Website Map
- `acm_certificate` - ACM Certificate Map
- `cloudfront_distribution` - CF Dist Map

### Authors 
- gspider8

### Future Updates
- Optional parameter to add CORS Configuration and additional S3 settings.
- Additional CloudFront Configurations. Maybe create a shared module.

### Developer Resources
- https://www.freecodecamp.org/news/aws-project-build-a-resume/
- https://medium.com/@Markus.Hanslik/setting-up-an-ssl-certificate-using-aws-and-terraform-198c6fb90743
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
- https://www.pulumi.com/ai/answers/nSYQFCwFgdVfuoBkW1qfGN/building-and-validating-aws-acm-certificates-with-terraform
- https://blog.demir.io/setup-an-s3-cloudfront-website-with-terraform-268d5230f05
