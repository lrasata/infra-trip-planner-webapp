# Target group unhealthy hosts
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.environment}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  evaluation_periods  = 1  # need 1 datapoint to trigger alarm
  period              = 60 # each datapoint = 60s
  statistic           = "Average"
  threshold           = 0

  dimensions = {
    TargetGroup  = module.alb.target_group_names[0]
    LoadBalancer = module.alb.lb_arn_suffix
  }

  alarm_description = "ALB target group has unhealthy hosts"
  alarm_actions     = [aws_sns_topic.alerts.arn]
}

# 5xx errors spike
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 5

  dimensions = {
    LoadBalancer = module.alb.lb_arn_suffix
  }

  alarm_description = "ALB is returning too many 5xx errors"
  alarm_actions     = [aws_sns_topic.alerts.arn]
}

# High latency
resource "aws_cloudwatch_metric_alarm" "alb_high_latency" {
  alarm_name          = "alb-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 2

  dimensions = {
    TargetGroup  = module.alb.target_group_names[0]
    LoadBalancer = module.alb.lb_arn_suffix
  }

  alarm_description = "ALB latency above 2 seconds for 10 minutes"
  alarm_actions     = [aws_sns_topic.alerts.arn]
}