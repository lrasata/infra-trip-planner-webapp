resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx" {
  alarm_name          = "${var.environment}-CloudFront-5xx-Errors-High"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = 1 # >1% errors
  alarm_description   = "Alert when CloudFront 5xx errors spike"
  alarm_actions       = [data.terraform_remote_state.backend_app.outputs.sns_topic_arn]

  dimensions = {
    DistributionId = aws_cloudfront_distribution.cdn.id
    Region         = "Global"
  }
}
