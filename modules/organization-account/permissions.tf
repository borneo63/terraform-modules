provider "aws" {
  region = var.aws_region
  alias  = "account"
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.main.id}:role/${var.admin_role}"
  }
}

data "aws_iam_policy_document" "account" {
  statement {
    actions   = ["sts:assumeRole"]
    resources = ["arn:aws:iam::${aws_organizations_account.main.id}:role/${var.admin_role}"]
  }
}

resource "aws_iam_policy" "account" {
  provider = aws.account
  name     = "OrganizationAccountFullAccess"
  policy   = data.aws_iam_policy_document.account.json
}

data "aws_ssoadmin_instances" "main" {}

data "aws_ssoadmin_permission_set" "main" {
  name         = var.admin_role
  instance_arn = data.aws_ssoadmin_instances.main.arns[0]
}

data "aws_identitystore_group" "main" {
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.admin_role
    }
  }
  identity_store_id = data.aws_ssoadmin_instances.main.identity_store_ids[0]
}

resource "aws_ssoadmin_account_assignment" "account" {
  permission_set_arn = data.aws_ssoadmin_permission_set.main.arn
  principal_id       = data.aws_identitystore_group.main.group_id
  principal_type     = "GROUP"

  target_id   = aws_organizations_account.main.id
  target_type = "AWS_ACCOUNT"

  instance_arn = data.aws_ssoadmin_instances.main.arns[0]
}
