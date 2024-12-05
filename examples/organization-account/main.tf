module "organization_account" {
  source = "git@github.com:borneo63/terraform-modules.git//modules/organization-account?ref=0.1.0"

  organizational_unit = var.organizational_unit

  account_name  = var.account_name
  account_email = var.account_email

  admin_role = var.admin_role

  domain_name = var.domain_name
  dns_records = var.dns_records

  tags = merge(
    {
      resource  = "aws-organization-account"
      source    = "infrastructure/implementations/organization-account"
      module    = "infrastructure/terraform-modules/aws/organization-account"
      terraform = true,
    },
    var.tags,
  )
}

variable "organizational_unit" {}
variable "account_name" {}
variable "account_email" {}
variable "admin_role" {}
variable "domain_name" {}
variable "dns_records" {}
variable "tags" {}
