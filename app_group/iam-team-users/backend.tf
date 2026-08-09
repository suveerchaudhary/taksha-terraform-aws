# Separate state - never touches dev/test/prod environments' state
terraform {
  backend "s3" {
    bucket         = "taksha-tf-state-bucket-219322923434"
    key            = "app_group/iam-team-users/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "taksha-tf-state-locks"
    encrypt        = true
  }
}