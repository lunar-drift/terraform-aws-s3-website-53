# S3 Static Website w/SSL
A terraform module to provide a DNS configuration with Route 53, a bucket to store files in, an SSL certificate managed by ACM, and a cloudfront distribution.

Public Repo: https://github.com/lunar-drift/terraform-aws-s3-website-53

### Requirements
- us-east 1 or else cloudfront / certificate / connect will not work
- Route 53 Zone already created

### Variables
#### Module Input Variables
- `apex_domain` - Apex domain name for hosted zone e.g. 'example.com'.
- `use_www` - [0/1] Option that creates a DNS record that points the www domain to the CloudFront Distribution.
- `cloudfront` - Configuration block for CloudFront distribution 
  - `cf_aliases` - 
  - `cf_geo_restriction_type`- 
  - `cf_geo_restriction_locations`- 
  

### Usage
```terraform
module "s3_website" {
  source  = "spacelift.io/gspider8/s3-website-53/aws"
  version = "0.2.0"

  apex_domain = "example.com"
  cloudfront  = {
    cf_aliases = ["example.com", "www.example.com"]
    cf_geo_restriction_type = "none"
    cf_geo_restriction_locations = []
  }
  # use_www = 1
}
```
### Outputs
- `route53_zone` - DNS Zone [map].
- `bucket` - Bucket [map].
- `bucket_policy` - Bucket Policy [map].
- `bucket_website_configuration` - Bucket Website [map].
- `acm_certificate` - ACM Certificate [map].
- `acm_certificate_validation` - ACM Certificate Validation [map].
- `cloudfront_distribution` - CF Dist [map].
- `route53_record` - Alias Record to point to CF Dist [map].

### Authors 
- gspider8

### Future Updates
- CloudFront Caching Configuration
- add error page handling to cloudfront distribution
- add in `subdomain` variable, defaulting to 0
- add in `cf_dist`, defaulting to 1
- subdomain and point_www_to_apex cannot both resolve true
  - add this in as a test case with no cloudfront distribution
- Optional parameter to add CORS Configuration and additional S3 settings.
### Developer Resources
- https://www.freecodecamp.org/news/aws-project-build-a-resume/
- https://medium.com/@Markus.Hanslik/setting-up-an-ssl-certificate-using-aws-and-terraform-198c6fb90743
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
- https://www.pulumi.com/ai/answers/nSYQFCwFgdVfuoBkW1qfGN/building-and-validating-aws-acm-certificates-with-terraform
- https://blog.demir.io/setup-an-s3-cloudfront-website-with-terraform-268d5230f05
