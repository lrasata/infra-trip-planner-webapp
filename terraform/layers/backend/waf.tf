resource "aws_wafv2_web_acl" "alb_waf" {
  name        = "${var.environment}-${var.app_id}-alb-waf"
  description = "WAF for ALB"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.environment}-${var.app_id}-AlbWAF"
    sampled_requests_enabled   = true
  }

  # Managed rule group (common protections)
  rule {
    name     = "${var.environment}-${var.app_id}-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.environment}-${var.app_id}-managedRules"
      sampled_requests_enabled   = true
    }
  }

  # Block known bots
  dynamic "rule" {
    for_each = var.blocked_bots_waf_cloudfront
    content {
      name     = "${var.environment}-${var.app_id}-Block${rule.value}"
      priority = 100 + index(var.blocked_bots_waf_cloudfront, rule.value) # safe offset

      statement {
        byte_match_statement {
          search_string = rule.value
          field_to_match {
            single_header {
              name = "user-agent" # must be lowercase
            }
          }
          positional_constraint = "CONTAINS"
          text_transformation {
            priority = 0
            type     = "NONE"
          }
        }
      }

      action {
        block {}
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.environment}-${var.app_id}-Block${rule.value}"
        sampled_requests_enabled   = true
      }
    }
  }

  # Rate limiting per IP
  rule {
    name     = "${var.environment}-${var.app_id}-RateLimitPerIP"
    priority = 200

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.environment}-${var.app_id}-rateLimit"
      sampled_requests_enabled   = true
    }
  }
}

# Associate the WAF with ALB
resource "aws_wafv2_web_acl_association" "alb_assoc" {
  resource_arn = module.alb.lb_arn
  web_acl_arn  = aws_wafv2_web_acl.alb_waf.arn
}
