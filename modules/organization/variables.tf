variable "aws_region" {
  type        = string
  description = "The main AWS region where resources are being created"
  default     = "eu-north-1"
}

variable "organization_name" {
  type        = string
  description = "The name of the organization to tag resources"
}

# Example:
#
# roles = [
#   {
#     name  = "admin"
#     value = "AdministratorAccess"
#   }
# ]
#
variable "roles" {
  type        = list(map(any))
  description = "The permission set details"
  default     = []
}

variable "tags" {
  type = map(any)
  default = {
    module    = "infrastructure/terraform-modules/aws/organization"
    terraform = true,
  }
}
