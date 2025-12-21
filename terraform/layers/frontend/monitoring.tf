# SNS
module "frontend_sns_alerts" {
  source = "../../common/modules/sns"

  environment        = var.environment
  notification_email = var.notification_email
  app_id             = var.app_id
  service_name       = module.cloudfront.cloudfront_domain_name
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx" {
  alarm_name          = "${var.environment}-${var.app_id}-CloudFront-5xx-Errors-High"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = 1 # >1% errors
  alarm_description   = "Alert when CloudFront 5xx errors spike"
  alarm_actions       = [module.frontend_sns_alerts.sns_topic_alerts_arn]

  dimensions = {
    DistributionId = module.cloudfront.cloudfront_id
    Region         = "Global"
  }
}
