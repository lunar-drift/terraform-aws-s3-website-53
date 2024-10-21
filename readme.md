## Getting Started

Public Repo: https://github.com/gspider8/terraform-aws-s3-website-53

#### Requirements

- us-east 1 or else cloudfront / certificate / connect will not work
- Existing domain name on route 53

#### Sample Usage

```HCL
module "s3_website" {
  source = "github.com/gspider8/terraform-aws-s3-website-53?ref=v0.0.2"

  domain_name = "example.com"
  tags = {
    Environment = "Dev"
    Project     = "project-name"
  }
}
```

## Developer Resources

- https://www.freecodecamp.org/news/aws-project-build-a-resume/
- https://medium.com/@Markus.Hanslik/setting-up-an-ssl-certificate-using-aws-and-terraform-198c6fb90743
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
- https://www.pulumi.com/ai/answers/nSYQFCwFgdVfuoBkW1qfGN/building-and-validating-aws-acm-certificates-with-terraform
- https://blog.demir.io/setup-an-s3-cloudfront-website-with-terraform-268d5230f05
