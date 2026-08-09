variable "aws_region" {
  type    = string
  default = "us-west-2"
}

# Deliberately false by default - real teams avoid long-lived access keys,
# using SSO/temporary credentials instead. Flip to true only to see the pattern.
variable "create_access_keys" {
  type    = bool
  default = false
}