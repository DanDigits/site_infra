locals {
  bucket_name       = lower(replace(var.domain_name, ".", "-"))
  s3_origin_id_site = local.bucket_name
}