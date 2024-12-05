variable "aws_region" {
  type        = string
  description = "The main AWS region where resources are being created"
  default     = "eu-north-1"
}

variable "organizational_unit" {
  type        = string
  description = "The name of the organization unit"
}

variable "tags" {
  type = map(any)
  default = {
    module    = "infrastructure/terraform-modules/aws/organizational-unit"
    terraform = true,
  }
}
