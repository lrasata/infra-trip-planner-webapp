# SNS
module "rds_sns_alerts" {
  source = "../../common/modules/sns"

  environment        = var.environment
  notification_email = var.notification_email
  app_id             = var.app_id
  service_name       = module.db.db_instance_identifier
}

# cloudwatch alarms
resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  alarm_name          = "${var.environment}-RDS-Free-Storage-Low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 2000000000 # ~2GB left
  alarm_description   = "Alert when RDS free storage space is low"
  alarm_actions       = [module.rds_sns_alerts.sns_topic_alerts_arn]

  dimensions = {
    DBInstanceIdentifier = module.db.db_instance_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_availability" {
  alarm_name          = "${var.environment}-RDS-CPUUtilization-Down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Alert when DB has CPU utilization of 0% for 5 minutes- RDS is potentially down"
  alarm_actions       = [module.rds_sns_alerts.sns_topic_alerts_arn]

  dimensions = {
    DBInstanceIdentifier = module.db.db_instance_identifier
  }
}
