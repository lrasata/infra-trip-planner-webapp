resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"
  is_ipv6_enabled     = true

  origin {
    domain_name              = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id # ensures that CloudFront can access the S3 bucket without making it public
    origin_id                = "${var.environment}-s3-bucket-origin"
  }

  origin {
    domain_name = module.alb.lb_dns_name
    origin_id   = "${var.environment}-alb-origin"

    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = 80 # required by Terraform but dont get confused only https is used
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = var.api_locations_domain_name
    origin_id   = "${var.environment}-api-gateway-origin"

    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = 80 # required by Terraform but dont get confused only https is used
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "X-Custom-Auth"
      value = local.auth_secret
    }
  }
  # -------------------------
  # Default behavior for frontend (S3)
  # -------------------------
  default_cache_behavior {
    target_origin_id = "${var.environment}-s3-bucket-origin"
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
      lambda_arn   = aws_lambda_function.spa_fallback.qualified_arn
      include_body = false
    }
  }

  # -------------------------
  # Behavior for backend/API (ALB)
  # -------------------------
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "${var.environment}-alb-origin"
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
    target_origin_id       = "${var.environment}-alb-origin"
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
    path_pattern           = "/locations*"
    target_origin_id       = "${var.environment}-api-gateway-origin"
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
  web_acl_id = aws_wafv2_web_acl.trip_planner_cloudfront_waf.arn

  depends_on = [
    aws_s3_bucket.s3_bucket,
    aws_cloudfront_origin_access_control.oac,
    aws_lambda_function.spa_fallback
  ]
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.environment}-s3-oac"
  description                       = "Access control for frontend S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# -------------------------
# ROUTE 53 ALIAS RECORD
# -------------------------
data "aws_route53_zone" "main" {
  name         = "epic-trip-planner.com" # this has to be static to allow retrieval of the  Route 53 Hosted Zone
  private_zone = false
}

resource "aws_route53_record" "cdn_alias_webapp" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.cloudfront_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}