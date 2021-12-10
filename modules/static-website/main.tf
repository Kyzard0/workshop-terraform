locals {
  enabled = var.enabled
  origin_path = var.origin_path
  origin_id = var.origin_id
  is_ipv6_enabled = var.is_ipv6_enabled
  bucket_name = var.bucket_name
}

/**
* CloudFront supports US East (N. Virginia) Region only,
* so an alias must be created to ensure the region is us-east-1.
*/
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

# Create the bucket (aws_s3_bucket.this)
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name
  acl    = "private"
}

# Create Origin Access Identity to read from the bucket
resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "${local.bucket_name}"
}

# Create IAM Policy to get objects from the bucket
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

# Create the distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id   = local.origin_id
    origin_path = local.origin_path

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  enabled             = local.enabled
  is_ipv6_enabled     = local.is_ipv6_enabled
  comment             = local.bucket_name
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
 
  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}


