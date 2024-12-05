module "organization" {
  source = "git@github.com:borneo63/terraform-modules.git//modules/organization?ref=0.1.0"

  organization_name = var.organization_name

  roles = var.roles

  tags = merge(
    {
      resource  = "aws-organization"
      source    = "infrastructure/implementations/organization"
      module    = "infrastructure/terraform-modules/aws/organization"
      terraform = true,
    },
    var.tags,
  )
}

variable "organization_name" {}
variable "roles" {}
variable "tags" {}
