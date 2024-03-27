# terraform init -reconfigure -backend-config="state.tfvars"
# terraform apply -var-file="variables.tfvars"

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

module "acm" {
  source      = "../modules/acm"
  domain_name = var.domain_name
}

module "s3" {
  source      = "../modules/s3"
  domain_name = var.domain_name
}

module "cloudfront" {
  source      = "../modules/cloudfront"
  domain_name = var.domain_name

  # ACM Imports
  site_certificate_arn = module.acm.site_certificate_arn

  # S3 Imports
  site_bucket_id                   = module.s3.site_bucket_id
  site_bucket_arn                  = module.s3.site_bucket_arn
  logging_bucket_domain_name       = module.s3.logging_bucket_domain_name
  site_bucket_regional_domain_name = module.s3.site_bucket_regional_domain_name
}