# CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${aws_ecs_service.ecs_service_trip_design.name}-CPUHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Alert when ECS CPU utilization exceeds 90%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    ClusterName = module.ecs_cluster.cluster_name
    ServiceName = aws_ecs_service.ecs_service_trip_design.name
  }
}

# Memory Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "${aws_ecs_service.ecs_service_trip_design.name}-MemoryHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Alert when ECS Memory utilization exceeds 90%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    ClusterName = module.ecs_cluster.cluster_name
    ServiceName = aws_ecs_service.ecs_service_trip_design.name
  }
}

# Unhealthy Tasks Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_unhealthy_tasks" {
  alarm_name          = "${aws_ecs_service.ecs_service_trip_design.name}-UnhealthyTasks"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnhealthyTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Alert when ECS service has unhealthy tasks"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    ClusterName = module.ecs_cluster.cluster_name
    ServiceName = aws_ecs_service.ecs_service_trip_design.name
  }
}