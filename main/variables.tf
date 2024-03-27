// https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/
// ACM ---------------------------------------------------------------------------------
variable "domain_name" {
  description = "Name of your domain"
  type        = string
  default     = "daniels.dev"
}

// Cloudfront ------------------------------------------------------------------------
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
  default = [
    {
      error_code            = 404
      response_code         = 404
      error_caching_min_ttl = 60
      response_page_path    = "/404.html"
    }
  ]
  description = "Custom error responses for cloudfront"
  type = list(object({
    error_code            = number
    response_code         = number
    error_caching_min_ttl = number
    response_page_path    = string
  }))
}

variable "compression" {
  description = "Enable compression on cloudfront dist."
  type        = bool
  default     = true
}

variable "ttl_min" {
  description = "Minimum TTL cache time in seconds"
  type        = number
  default     = 3600
}

variable "ttl_default" {
  description = "Default TTL cache time in seconds"
  type        = number
  default     = 86400
}

variable "ttl_max" {
  description = "Maximum TTL cache time in seconds"
  type        = number
  default     = 31536000
}

variable "viewer_protocol_policy" {
  description = "Specify viewer protocol behavior (usually HTTP/HTTPS)"
  type        = string
  default     = "redirect-to-https" // or allow-all or https-only
}

variable "ssl_minimum_protocol_version" {
  description = "SSL/TLS protocol version for cloudfront"
  type        = string
  default     = "TLSv1.2_2021"
}

// S3 ----------------------------------------------------------------------------------
variable "upload_template" {
  description = "Toggle pushing the given file (modify the variable template in /modules/s3.tf)"
  type        = bool
  default     = false
}