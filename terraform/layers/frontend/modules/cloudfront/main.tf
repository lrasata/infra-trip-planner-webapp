locals {
  static_web_app_origin       = "${var.environment}-${var.app_id}-s3-static-web-files-bucket-origin"
  uploads_bucket_origin       = "${var.environment}-${var.app_id}-s3-uploads-bucket-origin"
  alb_origin                  = "${var.environment}-${var.app_id}-alb-origin"
  locations_api_gw_origin     = "${var.environment}-${var.app_id}-locations-api-gateway-origin"
  file_uploader_api_gw_origin = "${var.environment}-${var.app_id}-file-uploader-api-gateway-origin"
}

resource "aws_cloudfront_distribution" "cdn" {
  tags = {
    Environment = var.environment
    App         = var.app_id
  }
  enabled             = true
  default_root_object = "index.html"
  is_ipv6_enabled     = true

  origin {
    domain_name              = var.static_web_app_bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id # ensures that CloudFront can access the S3 bucket without making it public
    origin_id                = local.static_web_app_origin
  }

  origin {
    domain_name              = var.uploads_bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = local.uploads_bucket_origin
  }

  origin {
    domain_name = var.alb_lb_dns_name
    origin_id   = local.alb_origin

    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = 80 # required by Terraform but dont get confused only https is used
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = var.api_locations_domain_name
    origin_id   = local.locations_api_gw_origin

    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = 80 # required by Terraform but dont get confused only https is used
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "x-api-gateway-locations-auth"
      value = var.locations_auth_secret
    }
  }

  origin {
    domain_name = var.api_file_upload_domain_name
    origin_id   = local.file_uploader_api_gw_origin

    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = 80 # required by Terraform but dont get confused only https is used
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "x-api-gateway-file-upload-auth"
      value = var.file_upload_auth_secret
    }
  }
  # -------------------------
  # Default behavior for frontend (S3)
  # -------------------------
  default_cache_behavior {
    target_origin_id = local.static_web_app_origin
    # Ensure any HTTP request from a user is redirected to HTTPS.
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400

    compress = true

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = var.spa_fallback_qualified_arn
      include_body = false
    }
  }

  # -------------------------
  # Behavior for backend (ALB)
  # -------------------------
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = local.alb_origin
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    compress = false
  }

  ordered_cache_behavior {
    path_pattern           = "/auth/*"
    target_origin_id       = local.alb_origin
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    compress = false
  }

  # -------------------------
  # Behavior for /uploads endpoint to fetch files from backend (Spring boot app)
  # -------------------------
  ordered_cache_behavior {
    path_pattern           = "/uploads/*"
    target_origin_id       = local.uploads_bucket_origin
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    compress = true
  }

  # -------------------------
  # Behavior for /thumbnails endpoint to fetch files from backend (Spring boot app)
  # -------------------------
  ordered_cache_behavior {
    path_pattern           = "/thumbnails/*"
    target_origin_id       = local.uploads_bucket_origin
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # cached for performance, reduce CloudFront/S3 load.
    min_ttl     = 60
    default_ttl = 3600
    max_ttl     = 86400
    compress    = true
  }

  # -------------------------
  # Behavior for Locations API
  # -------------------------
  ordered_cache_behavior {
    path_pattern           = "/locations*"
    target_origin_id       = local.locations_api_gw_origin
    allowed_methods        = ["HEAD", "GET", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  # -------------------------
  # Behavior for File-uploader API GW to upload files
  # -------------------------
  ordered_cache_behavior {
    path_pattern           = "/upload-url*"
    target_origin_id       = local.file_uploader_api_gw_origin
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cloudfront_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  aliases = [var.cloudfront_domain_name]

  # Attach WAF ACL
  web_acl_id = var.cloudfront_waf_arn

  depends_on = [aws_cloudfront_origin_access_control.oac]
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.environment}-${var.app_id}-s3-oac"
  description                       = "OAC for private S3 access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}