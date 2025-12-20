resource "aws_kms_key" "sns_cmk" {
  description         = "SNS CMK"
  enable_key_rotation = true
}

resource "aws_sns_topic" "alerts" {
  name = "${var.environment}-${var.app_id}-${var.service_name}-sns-topic"

  kms_master_key_id = aws_kms_key.sns_cmk.arn

  tags = {
    Service     = var.service_name
    Environment = var.environment
    App         = var.app_id
  }
}

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

