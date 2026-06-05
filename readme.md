# S3 Static Website w/SSL 

A handy OpenTofu module providing a private S3 origin, CloudFront distribution with Origin Access Control (OAC), ACM certificate, and Route 53 alias records for a static website all within the AWS free tier.

Public Repo: https://github.com/lunar-drift/terraform-aws-s3-website-53

### Requirements
- Provider must be configured for `us-east-1` (CloudFront requires ACM certificates in us-east-1)
- You must already own a domain name that you would like to use. 
- Manual intervention required to activate CloudFront Fixed Rate Plans [more on fixed rate plans]()

### Variables

| Name                      | Type           | Example                                      | Description                                                                        |
|---------------------------|----------------|----------------------------------------------|------------------------------------------------------------------------------------|
| `web_domain`              | `string`       | `google.com.`                                | Apex domain name that the site will be accessible from with trailing `.`.          |
| `cf_aliases`              | `list(string)` | -                                            | CloudFront distribution aliases (domain names)                                     |
| `cf_restricted_locations` | `list(string)` | `[]`                                         | ISO 3166-1 alpha-2 country codes to blacklist; empty list disables geo-restriction |
| `cf_allowed_methods`      | `list(string)` | `["GET", "HEAD"]`                            | HTTP methods CloudFront forwards to the origin                                     |
| `cf_cached_methods`       | `list(string)` | `["GET", "HEAD"]`                            | HTTP methods CloudFront caches responses for                                       |
| `client_name`             | `string`       | `""`                                         | Client identifier applied as a resource tag                                        |
| `environment`             | `string`       | `"production"`                               | Deployment environment applied as a resource tag                                   |
| `data_access_arn`         | `string`       | `"arn:aws:iam::<aws_acct>:role/<role_name>"` | IAM role ARN granted read/write/delete on the origin bucket                        |
| `resource_access_arn`     | `string`       | `"arn:aws:iam::<aws_acct>:role/<role_name>"` | IAM role ARN granted full access to all created resources.                         |

## Components
#### CloudFront Distribution
A CloudFront Distribution is how your website content is accessed by global users. 
This module takes advantage of the CloudFront Fixed Rate Plan Free Tier and includes the option to include all resources associated with that. 


Unless advanced configuration is applied, these resources will also be created:
- SSL Certificate to allow HTTPS access to site content/distribution.
- Route53 Hosted Zone (free after activating cloudfront fixed rate plans)
- S3 Bucket (origin) first 5 GB free with CloudFront Fixed Rate Plan

### DNS Records
If you would like to use another DNS Provider besides Route53, set the `dns_configuration` variable appropriately, you will
need to provision the acm certificate outside of this module and add it as an input variable. 
Additional steps are required to set up your static website that are not supported by this module. 
### Usage
ATTENTION
After applying, immediately login to AWS Management Console to activate your Fixed Rate Plan. 
There is a chance you will be charged $0.50 for your Hosted Zone when creating all resources at once but that will not be 
a recurring cost if you activate the CloudFront Fixed Rate Plan in the console. 
See steps here: TODO 

```terraform
variable "aws_management_account_number" { 
  type = string 
}

module "s3_website" {
  source  = "github.com/lunar-drift/terraform-aws-s3-website-53"
  version = "1.0.0"

  apex_domain         = "example.com"
  cf_aliases          = ["example.com", "www.example.com"]
  use_www             = 1
  client_name         = "acme"
  environment         = "production"
  data_access_arn     = "arn:aws:iam::${var.aws_management_account_number}:role/DataAccessRole"
  resource_access_arn = "arn:aws:iam::${var.aws_management_account_number}:role/DataAccessRole"
}
```

### Outputs

| Name                         | Description                         |
|------------------------------|-------------------------------------|
| `route53_zone`               | Route 53 hosted zone data source    |
| `bucket`                     | S3 origin bucket                    |
| `acm_certificate`            | ACM certificate                     |
| `acm_certificate_validation` | ACM certificate validation resource |
| `cloudfront_distribution`    | CloudFront distribution             |
| `cdn_domain_name`            | CloudFront distribution domain name |
| `cdn_distribution_id`        | CloudFront distribution ID          |
| `route53_record_apex`        | Route 53 apex alias record          |

### Authors
- gspider8
- lunar-drift
