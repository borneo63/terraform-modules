module "organizational_unit" {
  source = "git@github.com:borneo63/terraform-modules.git//modules/organizational-unit?ref=0.1.0"

  organizational_unit = var.organizational_unit

  tags = merge(
    {
      resource  = "aws-organizational-unit"
      source    = "infrastructure/implementations/organizational-unit"
      module    = "infrastructure/terraform-modules/aws/organizational-unit"
      terraform = true,
    },
    var.tags,
  )
}

variable "organizational_unit" {}
variable "tags" {}
