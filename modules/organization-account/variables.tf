variable "aws_region" {
  type        = string
  description = "The main AWS region where resources are being created"
  default     = "eu-north-1"
}

variable "organizational_unit" {
  type        = string
  description = "The organizational unit where the account will be created"
}

variable "account_name" {
  type        = string
  description = "The name of the new account to create"
}

variable "account_email" {
  type        = string
  description = "The email address associated to the new account"
}

variable "admin_role" {
  type        = string
  description = "Assign an administration role on account creation"
}

variable "domain_name" {
  type        = string
  description = "A principal domain the account will be associated with"
  default     = ""
}

variable "dns_records" {
  type        = list(map(any))
  description = "A list of DNS records to identify and associate the domain name"
  default     = []
}

variable "tags" {
  type = map(any)
  default = {
    module    = "infrastructure/terraform-modules/aws/organization-account"
    terraform = true,
  }
}
