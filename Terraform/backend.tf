terraform {
  backend "s3" {
    bucket = "s3terraform"
    key = "s3terraform/statefolder/statefile"
    region = "us-east-1"
    encrypt = true
  }
}
