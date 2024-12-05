provider "aws" {
  region = var.aws_region
  alias  = "root"
}

resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "account.amazonaws.com",
    "sso.amazonaws.com"
  ]
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY"
  ]
  feature_set = "ALL"
}
