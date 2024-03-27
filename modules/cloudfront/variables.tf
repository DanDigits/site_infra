variable "domain_name" {
  description = "Name of your domain"
  type        = string
}

variable "ipv6" {
  description = "Enable support for IPV6 on cloudfront dist."
  type        = bool
  default     = true
}

variable "http_version" {
  description = "The http version for cloudfront to use"
  type        = string
  default     = "http3"
}

variable "price_class" {
  description = "Cloudfront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "custom_error_responses" {
  description = "Custom error responses for cloudfront"
  type = list(object({
    error_code            = number
    response_code         = number
    error_caching_min_ttl = number
    response_page_path    = string
  }))
  default = [
    {
      error_code            = 404
      response_code         = 404
      error_caching_min_ttl = 60
      response_page_path    = "/404.html"
    }
  ]
}

variable "compression" {
  description = "Enable compression on cloudfront dist."
  type        = bool
  default     = true
}

variable "ttl_min" {
  description = "Minimum TTL Cache time in seconds"
  type        = number
  default     = 3600
}

variable "ttl_default" {
  description = "Default TTL Cache time in seconds"
  type        = number
  default     = 86400
}

variable "ttl_max" {
  description = "Maximum TTL Cache time in seconds"
  type        = number
  default     = 31536000
}

variable "viewer_protocol_policy" {
  description = "Specify viewer protocol behavior (usually HTTP/HTTPS)"
  type        = string
  default     = "redirect-to-https"
}

variable "ssl_minimum_protocol_version" {
  description = "SSL/TLS protocl version for cloudfront"
  type        = string
  default     = "TLSv1.2_2021"
}

// ACM Certificate ----------------------------------------------------------------------------------------------------
variable "site_certificate_arn" {
  description = "Website CA Certificate ARN"
  type        = string
}

// S3 Buckets ---------------------------------------------------------------------------------------------------------
variable "site_bucket_id" {
  description = "Website bucket ID"
  type        = string
}

variable "site_bucket_arn" {
  description = "ARN of the website bucket"
  type        = string
}

variable "logging_bucket_domain_name" {
  description = "Domain name of the logging bucket"
  type        = string
}

variable "site_bucket_regional_domain_name" {
  description = "Domain name of the site bucket"
  type        = string
}