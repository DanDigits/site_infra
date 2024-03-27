// Manages access control with a dist. sourced from an s3 bucket or mediastore
resource "aws_cloudfront_origin_access_control" "site_s3" {
  name                              = var.domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

// Establish a cloudfront function for the dist.
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function
resource "aws_cloudfront_function" "site_function" {
  name    = local.bucket_name
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = file("../modules/cloudfront/function.js")
}

// Policy to be attached to every response from respective cloudfront dist. 
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy
resource "aws_cloudfront_response_headers_policy" "site_response_headers" {
  name = local.bucket_name

  # remove_headers_config {
  #   Remove headers from response
  # }

  security_headers_config {
    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }

    referrer_policy {
      override        = true
      referrer_policy = "strict-origin-when-cross-origin"
    }

    strict_transport_security {
      access_control_max_age_sec = "31536000"
      include_subdomains         = true
      override                   = true
      preload                    = true
    }

    xss_protection {
      mode_block = true
      override   = true
      protection = true
    }
  }
}

// The cloudfront distribution
resource "aws_cloudfront_distribution" "site" {
  aliases             = [data.aws_route53_zone.zone.name, "www.${data.aws_route53_zone.zone.name}"]
  default_root_object = null // or "index.html" or whatever specific file you wanna serve at rool URL
  enabled             = true
  is_ipv6_enabled     = var.ipv6
  http_version        = var.http_version
  price_class         = var.price_class


  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = var.compression
    target_origin_id = local.s3_origin_id_site

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    // Associate the requisite function to this dist. cache
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.site_function.arn
    }

    response_headers_policy_id = aws_cloudfront_response_headers_policy.site_response_headers.id
    min_ttl                    = var.ttl_min
    default_ttl                = var.ttl_default
    max_ttl                    = var.ttl_max
    viewer_protocol_policy     = var.viewer_protocol_policy
  }

  logging_config {
    include_cookies = false
    bucket          = var.logging_bucket_domain_name
    prefix          = "cloudfront_${local.bucket_name}/"
  }

  origin {
    domain_name              = var.site_bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site_s3.id
    origin_id                = local.s3_origin_id_site
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.site_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = var.ssl_minimum_protocol_version
  }
}

// Attaches the policy to the cloudfront distribution
resource "aws_s3_bucket_policy" "site_s3" {
  bucket = var.site_bucket_id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "PolicyForCloudFrontAccessToResourcesBucket",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipal",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${var.site_bucket_arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : aws_cloudfront_distribution.site.arn
          }
        }
      },
      {
        "Sid" : "AllowSSLRequestsOnly",
        "Effect" : "Deny",
        "Principal" : "*"
        "Action" : "s3:GetObject",
        "Resource" : "${var.site_bucket_arn}/*",
        "Condition" : {
          "Bool" : {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  })
}

// Requisite DNS records from domain to cloudfront dist. -------------------------------------------------------------------------
resource "aws_route53_record" "site_a" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site_aaaa" {
  count   = var.ipv6 ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = ""
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site_a_www" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "site_aaaa_www" {
  count   = var.ipv6 ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "www"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}




































