data "aws_route53_zone" "zone" {
  name         = var.domain_name
  private_zone = false
}