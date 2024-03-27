output "site_bucket_id" {
  description = "Website bucket ID"
  value       = aws_s3_bucket.site.id
}

output "site_bucket_arn" {
  description = "ARN of the website bucket"
  value       = aws_s3_bucket.site.arn
}

output "logging_bucket_domain_name" {
  description = "Domain name of the logging bucket"
  value       = aws_s3_bucket.logging.bucket_domain_name
}

output "site_bucket_regional_domain_name" {
  description = "Domain name of the site bucket"
  value       = aws_s3_bucket.site.bucket_regional_domain_name
}

