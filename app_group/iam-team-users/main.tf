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
  region = var.aws_region
}

# Load team members from JSON file
locals {
  team_members = jsondecode(file("${path.module}/team_members.json"))
}

# Group all new dev-team members belong to
resource "aws_iam_group" "dev_team" {
  name = "dev-team"
}

# Scoped, read-only baseline - real least-privilege dev access would be
# narrower still (e.g. our restricted EC2 policy from bootstrap/oidc),
# kept broad+read-only here to keep this module focused on the IAM-user
# pattern itself, not re-deriving the EC2 policy.
resource "aws_iam_group_policy_attachment" "dev_team_readonly" {
  group      = aws_iam_group.dev_team.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Standard "force MFA" pattern: lets a user manage their own password/MFA
# device, but denies everything else until MFA is actually enabled and
# present on the session. This is the real corporate onboarding pattern.
resource "aws_iam_policy" "require_mfa" {
  name = "require-mfa-dev-team"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSelfManageCredentials"
        Effect = "Allow"
        Action = [
          "iam:ChangePassword",
          "iam:GetUser",
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice"
        ]
        Resource = "arn:aws:iam::*:user/$${aws:username}"
      },
      {
        Sid       = "DenyEverythingElseWithoutMFA"
        Effect    = "Deny"
        NotAction = ["iam:ChangePassword", "iam:GetUser", "iam:CreateVirtualMFADevice", "iam:EnableMFADevice", "iam:ListMFADevices", "iam:ResyncMFADevice", "sts:GetSessionToken"]
        Resource  = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "dev_team_mfa" {
  group      = aws_iam_group.dev_team.name
  policy_arn = aws_iam_policy.require_mfa.arn
}

# One user per team member - the for_each pattern, same technique as
# our three OIDC roles, applied to people instead of environments
resource "aws_iam_user" "team" {
  for_each      = toset(local.team_members)
  name          = each.key
  force_destroy = true # allows destroy even if the user has extra attached items

  tags = { Team = "dev", ManagedBy = "terraform" }
}

resource "aws_iam_user_group_membership" "team" {
  for_each = aws_iam_user.team
  user     = each.value.name
  groups   = [aws_iam_group.dev_team.name]
}

# Console access - real onboarding pattern: forced reset on first login
resource "aws_iam_user_login_profile" "team" {
  for_each                = aws_iam_user.team
  user                    = each.value.name
  password_reset_required = true
  password_length         = 16
}

# Optional: programmatic access keys - off by default, see variables.tf note
resource "aws_iam_access_key" "team" {
  for_each = var.create_access_keys ? aws_iam_user.team : {}
  user     = each.value.name
}