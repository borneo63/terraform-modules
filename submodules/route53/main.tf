resource "aws_route53_zone" "root" {
  provider = aws.global
  name     = var.root_domain

  tags = var.tags
}

resource "aws_acm_certificate" "root" {
  provider = aws.global

  domain_name       = var.root_domain
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.root_domain}",
  ]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_route53_zone.root
  ]

  tags = var.tags
}

resource "aws_route53_record" "validation" {
  provider = aws.global

  for_each = {
    for dvo in aws_acm_certificate.root.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.root.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60

  allow_overwrite = true
}

# resource "aws_acm_certificate_validation" "root" {
#   provider = aws.global

#   certificate_arn = aws_acm_certificate.root.arn
#   validation_record_fqdns = [
#     for record in aws_route53_record.validation : record.fqdn
#   ]

#   timeouts {
#     create = "10m"
#   }
# }


resource "aws_route53_record" "list" {
  provider = aws.global
  count    = length(var.dns_records)

  zone_id = aws_route53_zone.root.zone_id
  name    = var.dns_records[count.index].name
  type    = var.dns_records[count.index].type
  records = [var.dns_records[count.index].value]
  ttl     = 60

  allow_overwrite = true
}
