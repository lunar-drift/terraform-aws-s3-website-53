# S3 Static Website w/SSL for a client

One handy OpenTofu module providing a private S3 origin, CloudFront distribution with Origin Access Control (OAC), ACM certificate, and Route 53 alias records for a static website all within the AWS free tier.


Public Repo: https://github.com/lunar-drift/terraform-aws-s3-website-53

### Requirements
- Provider must be configured for `us-east-1` (CloudFront requires ACM certificates in us-east-1)
- Route 53 hosted zone must already exist for `apex_domain`
- Manual intervention required to activate CloudFront Fixed Rate Plans [more on fixed rate plans]()

### Variables

| Name                      | Type           | Default                                      | Description                                                                        |
|---------------------------|----------------|----------------------------------------------|------------------------------------------------------------------------------------|
| `apex_domain`             | `string`       | -                                            | Apex domain name for the hosted zone and S3 bucket                                 |
| `cf_aliases`              | `list(string)` | -                                            | CloudFront distribution aliases (domain names)                                     |
| `use_www`                 | `number`       | `0`                                          | Set to `1` to create a `www.` Route 53 alias record                                |
| `cf_restricted_locations` | `list(string)` | `[]`                                         | ISO 3166-1 alpha-2 country codes to blacklist; empty list disables geo-restriction |
| `cf_allowed_methods`      | `list(string)` | `["GET", "HEAD"]`                            | HTTP methods CloudFront forwards to the origin                                     |
| `cf_cached_methods`       | `list(string)` | `["GET", "HEAD"]`                            | HTTP methods CloudFront caches responses for                                       |
| `client_name`             | `string`       | `""`                                         | Client identifier applied as a resource tag                                        |
| `environment`             | `string`       | `"production"`                               | Deployment environment applied as a resource tag                                   |
| `data_access_arn`         | `string`       | `"arn:aws:iam::<aws_acct>:role/<role_name>"` | IAM role ARN granted read/write/delete on the origin bucket                        |
| `resource_access_arn`     | `string`       | `"arn:aws:iam::<aws_acct>:role/<role_name>"` | IAM role ARN granted full access to all created resources.                         |

### Usage



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
