# Separate state - independent of environments/ and other app_group modules
terraform {
  backend "s3" {
    bucket         = "taksha-tf-state-bucket-219322923434"
    key            = "app_group/vpc/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "taksha-tf-state-locks"
    encrypt        = true
  }
}