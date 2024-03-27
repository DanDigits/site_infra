// Create SSL/TLS Cert
resource "aws_acm_certificate" "site" {
  domain_name = data.aws_route53_zone.zone.name
  # key_algorithm     = "EC_secp384r1" 
  key_algorithm = "RSA_2048"
  # validation_method = "EMAIL"
  validation_method = "DNS"
  subject_alternative_names = [
    "*.${data.aws_route53_zone.zone.name}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

// Validate the Route53 site through declated validation option
resource "aws_route53_record" "site_validation" {
  for_each = {
    for validation_option in aws_acm_certificate.site.domain_validation_options : validation_option.domain_name => {
      name   = validation_option.resource_record_name
      record = validation_option.resource_record_value
      type   = validation_option.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.zone.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]

  depends_on = [aws_acm_certificate.site]
}

// Verify the Route53 records are validated
resource "aws_acm_certificate_validation" "site" {
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for record in aws_route53_record.site_validation : record.fqdn]

  timeouts {
    create = "5m"
  }

  depends_on = [aws_route53_record.site_validation]
}

// Issue CA and comment no issues with instantiating an Amazon
resource "aws_route53_record" "site_caa" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = ""
  type    = "CAA"
  ttl     = "3600"
  records = [
    "0 issue \"amazon.com\"",
    "0 issuewild \"amazon.com\""
  ]
}