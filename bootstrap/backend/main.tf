# This is the main.tf file for the backend of the Taksha project.
terraform {
  # This is the required version of Terraform.
  required_version = ">= 1.6.0"
  # This is the required providers for the backend.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# This is the provider for the backend.
provider "aws" {
  region = "us-west-2"
}

# This is the resource for the S3 bucket for the backend.
resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = "taksha-tf-state-bucket-219322923434"
  lifecycle {
    prevent_destroy = true # This prevents the S3 bucket from being destroyed.
  }
}

resource "aws_s3_bucket_versioning" "tf_state_bucket_versioning" {
  bucket = aws_s3_bucket.tf_state_bucket.id
  versioning_configuration {
    status = "Enabled" # This enables versioning for the S3 bucket.
  }
}

# This is the resource for the DynamoDB table for the backend.
resource "aws_dynamodb_table" "tf_state_lock_table" {
  name         = "taksha-tf-state-locks"
  billing_mode = "PAY_PER_REQUEST" # This sets the billing mode for the DynamoDB table to PAY_PER_REQUEST.
  hash_key     = "LockID"          # This sets the hash key for the DynamoDB table to LockID.
  attribute {
    name = "LockID" # This sets the name of the attribute for the DynamoDB table to LockID.
    type = "S"      # This sets the type of the attribute for the DynamoDB table to S (String).
  }
}
