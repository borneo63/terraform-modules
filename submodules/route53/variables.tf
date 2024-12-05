variable "aws_region" {
  type        = string
  description = "The global AWS region where DNS records and certificates are created"
  default     = "us-east-1"
}

variable "root_domain" {
  type        = string
  description = "A principal domain name to create a hosted zone and DNS records"
  default     = ""
}

# Example usage:
#
# dns_records = [
#   {
#     type  = "CNAME"
#     name  = "www.my-company.io"
#     value = "my-company.io"
#   },
#   {
#     type  = "A"
#     name  = "development.my-company.io"
#     value = "172.21.30.20"
#   },
#   {
#     type  = "A"
#     name  = "db.my-company.io"
#     value = "db-prod.cep3rz.eu-north-1.rds.amazonaws.com."
#   }
# ]
#
variable "dns_records" {
  type        = list(map(any))
  description = "A list of records to identify and associate the domain name"
  default     = []
}

variable "tags" {
  type = map(any)
  default = {
    module    = "infrastructure/terraform-modules/aws/route53"
    terraform = true,
  }
}
