# Provider - same account, same region as everything else
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Trust relationship between AWS and GitHub's OIDC token issuer.
# This is a one-time, account-wide resource - only ever created once,
# no matter how many repos/roles use it later.
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # This is the SHA-1 thumbprint for the GitHub OIDC token issuer. fixed, published value everyone using GitHub Actions + AWS OIDC uses verbatim
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# One IAM role per environment. Each is only assumable by workflow runs
# coming from suveerchaudhary/taksha-terraform-aws, running under that
# specific GitHub Environment (dev/test/prod).
resource "aws_iam_role" "github_actions" {
  for_each = toset(["dev", "test", "prod"])

  name = "github-actions-taksha-terraform-aws-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = ["sts:AssumeRoleWithWebIdentity", "sts:TagSession"]
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # New immutable format (repos created after July 15, 2026 use owner-id/repo-id, not just names)
          "token.actions.githubusercontent.com:sub" = "repo:suveerchaudhary@7366297/taksha-terraform-aws@1326214576:environment:${each.key}"
        }
      }
    }]
  })
}

# Permissions each role gets - scoped to what Terraform actually needs:
# EC2 for the resources we deploy, plus S3/DynamoDB for state access.
resource "aws_iam_role_policy" "permissions" {
  for_each = aws_iam_role.github_actions

  name = "terraform-permissions"
  role = each.value.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:StopInstances",
          "ec2:StartInstances",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:ModifyInstanceAttribute"
        ]
        Resource = "*"
      },
      {
        Sid    = "StateBucket"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          "arn:aws:s3:::taksha-tf-state-bucket-219322923434",
          "arn:aws:s3:::taksha-tf-state-bucket-219322923434/*"
        ]
      },
      {
        Sid      = "StateLock"
        Effect   = "Allow"
        Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
        Resource = "arn:aws:dynamodb:*:*:table/taksha-tf-state-locks"
      }
    ]
  })
}

# Outputs - you'll paste these into GitHub Environment secrets later
output "role_arns" {
  value = { for env, role in aws_iam_role.github_actions : env => role.arn }
}