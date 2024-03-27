output "site_certificate_arn" {
  description = "Website CA Certificate ARN"
  value       = aws_acm_certificate.site.arn
  depends_on  = [aws_acm_certificate.site, aws_acm_certificate_validation.site]
}