# --- aws-s3-53/variables.tf ---

variable "tags" {
  type = map(string)
  default = {
    Terraform = "True"
  }
}

variable "domain_name" {
  type = string
}

variable "_create_r53_zone" {
  default = false
  type = bool
}