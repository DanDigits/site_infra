// Site S3 Bucket -------------------------------------------------------------------------------
resource "aws_s3_bucket" "site" {
  bucket        = local.bucket_name
  force_destroy = true
  # 
  #  lifecycle {
  #    prevent_destroy = true
  #  }
}

// Set bucket to private
resource "aws_s3_bucket_public_access_block" "site_private" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

// Encrypt bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "site_encryption" {
  bucket = aws_s3_bucket.site.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// Set logging bucket to logging bucket created below
resource "aws_s3_bucket_logging" "site_logging" {
  bucket        = aws_s3_bucket.site.id
  target_bucket = aws_s3_bucket.logging.id
  target_prefix = "s3_${aws_s3_bucket.site.id}/"
  depends_on    = [aws_s3_bucket.logging]
}



// Logging S3 Bucket ----------------------------------------------------------------------------
resource "aws_s3_bucket" "logging" {
  bucket        = "${local.bucket_name}-logging"
  force_destroy = true
  # 
  # lifecycle {
  #   #  prevent_destroy = true
  # }
}

// Set bucket to transition entries to class SandardIA after 30 days, and delete after 365
resource "aws_s3_bucket_lifecycle_configuration" "logging_lifecycle" {
  bucket = aws_s3_bucket.logging.id

  rule {
    id     = "transition_to_IA"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

  rule {
    id     = "delete_old_files"
    status = "Enabled"
    expiration {
      days = 365
    }
  }
}

// Set bucket to private
resource "aws_s3_bucket_public_access_block" "logging_private" {
  bucket                  = aws_s3_bucket.logging.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

// Encrypt bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "logging_encryption" {
  bucket = aws_s3_bucket.logging.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

// Set ownership to preferred, which enables use of ACLs
// https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html
resource "aws_s3_bucket_ownership_controls" "logging_ownership" {
  bucket = aws_s3_bucket.logging.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

// Starting in April 2023, you need to to override the best practice and enable ACLs when sending CloudFront logs to S3
// https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#AccessLogsBucketAndFileOwnership
resource "aws_s3_bucket_acl" "logging_acl" {
  bucket     = aws_s3_bucket.logging.id
  acl        = "log-delivery-write"
  depends_on = [aws_s3_bucket_ownership_controls.logging_ownership]
}




// Upload a given file
resource "aws_s3_object" "template" {
  count        = var.upload_template ? 1 : 0
  bucket       = aws_s3_bucket.site.id
  key          = "myFile.html"                       // Object name in bucket
  source       = "index.html"                        // Object location in local directory
  content_type = "text/html"                         // All Valid MIME Types are valid for this input
  etag         = filemd5("../modules/s3/index.html") // Used for forced cache invalidation
}