Getting Started

Requirements
- us-east 1 or else cloudfront / certificate / connect will not work
- Change variables in variables.tf
- Set up domain name

Create Hosted zone for non-aws owned domain
1. Create Hosted Zone
    1. enter domain name
    2. public
    3. Enter name servers on current domain name provider page
        Squarespace > Domain > DNS > Domain Nameservers
        Create an A record in your hosted zone
    Simple, Alias, Point to s3 website, ensure health Go to Certificate Manager > Request a Certificate if you don't have one

Set up Cloud Front

Create terraform.tfvars file and add




variable "certificate_arn" {




    type = string




    default = "us-east-1"




}

Create S3 Infrastructure on AWS




cd iac/terraform/aws-s3-53




terraform apply -auto-approve

Add files to bucket




cd ../../.. # to basic-website dir




./iac/bin/put-object.sh <domain> <template-name>









# for resume_website example




./iac/bin/put-object.sh geotorus.org resume-website

to-do

    make it so i can terraform destroy by deleting objects from bucket3
    implement certificate issuance verification

Resources

https://www.freecodecamp.org/news/aws-project-build-a-resume/
cloudfront and certificate terraform

https://medium.com/@Markus.Hanslik/setting-up-an-ssl-certificate-using-aws-and-terraform-198c6fb90743 https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation https://www.pulumi.com/ai/answers/nSYQFCwFgdVfuoBkW1qfGN/building-and-validating-aws-acm-certificates-with-terraform https://blog.demir.io/setup-an-s3-cloudfront-website-with-terraform-268d5230f05
