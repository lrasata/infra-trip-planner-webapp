resource "aws_sns_topic" "alerts" {
  name = "${aws_ecs_service.ecs_service_trip_planner.name}-alerts"
}

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}