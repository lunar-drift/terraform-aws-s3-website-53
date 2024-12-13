# S3 Static Website w/SSL
A terraform module to provide a DNS configuration with Route 53, a bucket to store files in,
an SSL certificate managed by ACM, and a cloudfront distribution.

Public Repo: https://github.com/gspider8/terraform-aws-s3-website-53

### Requirements
- us-east 1 or else cloudfront / certificate / connect will not work
- Route 53 Zone already created

### Module Input Variables
- `domain_name` - Base domain name for hosted zone e.g. 'example.com'.
- `tags` - Map of key/value pairs to tag certain created items

#### Usage
```terraform
module "s3_website" {
  source  = "spacelift.io/gspider8/s3-website-53/aws"
  version = "0.0.0"

  domain_name = "example.com"
  tags = {
    Environment = "Development"
    Project     = "project-name"
  }
}
```
### 

### Future Updates

- Optional parameter to add CORS Configuration

## Developer Resources

- https://www.freecodecamp.org/news/aws-project-build-a-resume/
- https://medium.com/@Markus.Hanslik/setting-up-an-ssl-certificate-using-aws-and-terraform-198c6fb90743
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
- https://www.pulumi.com/ai/answers/nSYQFCwFgdVfuoBkW1qfGN/building-and-validating-aws-acm-certificates-with-terraform
- https://blog.demir.io/setup-an-s3-cloudfront-website-with-terraform-268d5230f05
