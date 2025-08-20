terraform {
  backend "s3" {
    bucket = "final-project-bucket-unique-name"
    key = "final-project-bucket-unique-name/statefolder/statefile"
    region = "us-east-1"
    encrypt = true
  }
}
