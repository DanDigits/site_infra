// This code is to be run prior to that of the main.tf file, 
// as a Route 53 hosted zone requires manual intervention with third party registrars
// to get up and running due to DNS/NS certificates:
// https://www.linkedin.com/pulse/how-integrate-third-party-dns-provider-route-53-milad-rezaeighale/

terraform {
  required_version = "~> 1.5.7"

  backend "s3" {
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_route53_zone" "site" {
  name = var.domain_name
}

resource "aws_route53_record" "site_nameservers" {
  zone_id         = aws_route53_zone.site.zone_id
  name            = aws_route53_zone.site.name
  type            = "NS"
  ttl             = "3600"
  allow_overwrite = true
  records         = aws_route53_zone.site.name_servers
}