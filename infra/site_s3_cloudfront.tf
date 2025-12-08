############################################
# S3 Bucket - Static Site Content
# Purpose: Private bucket for portfolio static files
############################################

resource "aws_s3_bucket" "site" {
  bucket = local.site_bucket_name

  tags = local.tags
}

############################################
# S3 Bucket Default Encryption
# Purpose: Encrypt all objects at rest with SSE-S3
############################################
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

############################################
# S3 Bucket Versioning - Site
# Purpose: Protect against accidental deletes and overwrites
############################################

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = "Enabled"
  }
}

############################################
# S3 Bucket Ownership Controls — Site
# Purpose: Disable ACLs, bucket-owner enforced
############################################
resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################
# S3 Bucket - CloudFront Logs
# Purpose: Store CDN access logs (no extra logging/versioning on logs bucket)
############################################
#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "logs" {
  bucket = local.cf_logs_bucket_name

  tags = local.tags
}


############################################
# S3 Bucket Ownership and Public Access Block — Logs
# Purpose: Allow ACLs for log delivery (no BucketOwnerEnforced)
############################################
resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################
# S3 Bucket Default Encryption (Logs)
# Purpose: Encrypt access logs at rest with SSE-S3
############################################
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

############################################
# S3 Bucket Access Logging - Site
# Purpose: Enable access logging for main site bucket
############################################

resource "aws_s3_bucket_logging" "site_logging" {
  bucket = aws_s3_bucket.site.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3/"
}

############################################
# CloudFront Origin Access Control (OAC)
# Purpose: Secure access from CloudFront to S3
############################################

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for ${var.project_name} static site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

############################################
# ACM Certificate for Domain
# Purpose: TLS certificate for rusets.com (in us-east-1)
############################################

resource "aws_acm_certificate" "site" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

############################################
# CloudFront Distribution
# Purpose: Serve static site over HTTPS with custom domain
############################################
#tfsec:ignore:aws-cloudfront-enable-waf
resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  comment             = "${var.project_name} static site"
  default_root_object = "index.html"

  aliases = [
    var.domain_name,
  ]

  ############################################
  # Logging configuration (CloudFront → S3 logs bucket)
  ############################################
  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = "cloudfront/"
  }

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-origin-${aws_s3_bucket.site.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin-${aws_s3_bucket.site.id}"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    compress = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ##########################################
  # Custom error responses → /error.html
  ##########################################

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/error.html"
    error_caching_min_ttl = 60
  }

  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/error.html"
    error_caching_min_ttl = 60
  }

  custom_error_response {
    error_code            = 500
    response_code         = 500
    response_page_path    = "/error.html"
    error_caching_min_ttl = 60
  }

  custom_error_response {
    error_code            = 502
    response_code         = 500
    response_page_path    = "/error.html"
    error_caching_min_ttl = 60
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = local.tags
}

############################################
# S3 Bucket Policy - Allow CloudFront OAC
# Purpose: Let CloudFront distribution read private S3 content
############################################

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudFrontRead"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.site.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.site.arn
          }
        }
      }
    ]
  })
}
