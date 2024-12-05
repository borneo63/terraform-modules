provider "aws" {
  region = "us-east-1"
  alias  = "certificates"
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.main.id}:role/${var.admin_role}"
  }
}

module "route53" {
  source = "git@github.com:borneo63/terraform-modules.git//submodules/route53?ref=0.1.0"

  providers = {
    aws.global = aws.certificates
  }

  root_domain = var.domain_name
  dns_records = var.dns_records

  tags = merge(
    {
      resource  = "aws-organization-account"
      source    = "infrastructure/implementations/organization-account"
      module    = "infrastructure/terraform-modules/aws/organization-account"
      submodule = "infrastructure/terraform-modules/aws/route53"
      terraform = true,
    },
    var.tags,
  )
}
