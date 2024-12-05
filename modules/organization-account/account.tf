provider "aws" {
  region = var.aws_region
  alias  = "root"
}

data "aws_organizations_organization" "root" {}

data "aws_organizations_organizational_unit" "main" {
  name      = var.organizational_unit
  parent_id = data.aws_organizations_organization.root.roots[0].id
}

resource "aws_organizations_account" "main" {
  name  = var.account_name
  email = var.account_email

  role_name = var.admin_role
  parent_id = data.aws_organizations_organizational_unit.main.id

  close_on_deletion = true

  tags = var.tags
}
