# Remote state for the dev environment - separate state file from test/prod
terraform {
  backend "s3" {
    bucket         = "taksha-tf-state-bucket-219322923434"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "taksha-tf-state-locks"
    encrypt        = true
  }
}