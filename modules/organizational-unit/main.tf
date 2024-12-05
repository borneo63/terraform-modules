provider "aws" {
  region = var.aws_region
}

data "aws_organizations_organization" "root" {
}

resource "aws_organizations_organizational_unit" "main" {
  name      = var.organizational_unit
  parent_id = data.aws_organizations_organization.root.roots[0].id

  tags = merge(
    {
      module    = "infrastructure/terraform-modules/aws/organizational-unit"
      terraform = true,
    },
    var.tags,
  )
}
