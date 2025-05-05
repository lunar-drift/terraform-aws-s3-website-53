# --- s3-website-53.storages.variables ---

variable "bucket_name" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
    Terraform = "True"
  }
}