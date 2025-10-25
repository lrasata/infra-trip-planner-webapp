resource "aws_sns_topic" "alerts" {
  name = "${module.db.db_instance_identifier}-alerts"
}

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}