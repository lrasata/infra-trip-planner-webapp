# SNS
module "backend_sns_alerts" {
  source = "../../common/modules/sns"

  environment        = var.environment
  notification_email = var.notification_email
  app_id             = var.app_id
  service_name       = module.ecs_cluster.cluster_name
}

# ECS - CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${module.ecs_service.ecs_service_name}-CPUHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Alert when ECS CPU utilization exceeds 90%"
  alarm_actions       = [module.backend_sns_alerts.sns_topic_alerts_arn]
  dimensions = {
    ClusterName = module.ecs_cluster.cluster_name
    ServiceName = module.ecs_service.ecs_service_name
  }
}

# ECS - Memory Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "${module.ecs_service.ecs_service_name}-MemoryHigh"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "Alert when ECS Memory utilization exceeds 90%"
  alarm_actions       = [module.backend_sns_alerts.sns_topic_alerts_arn]
  dimensions = {
    ClusterName = module.ecs_cluster.cluster_name
    ServiceName = module.ecs_service.ecs_service_name
  }
}

# ECS - Unhealthy Tasks Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_unhealthy_tasks" {
  alarm_name          = "${module.ecs_service.ecs_service_name}-UnhealthyTasks"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnhealthyTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Alert when ECS service has unhealthy tasks"
  alarm_actions       = [module.backend_sns_alerts.sns_topic_alerts_arn]
  dimensions = {
    ClusterName = module.ecs_cluster.cluster_name
    ServiceName = module.ecs_service.ecs_service_name
  }
}

# ALB - Target group unhealthy hosts
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
    TargetGroup  = module.alb.alb_target_group_names[0]
    LoadBalancer = module.alb.lb_arn_suffix
  }

  alarm_description = "ALB target group has unhealthy hosts"
  alarm_actions     = [module.backend_sns_alerts.sns_topic_alerts_arn]
}

# ALB - 5xx errors spike
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
  alarm_actions     = [module.backend_sns_alerts.sns_topic_alerts_arn]
}

# ALB - High latency
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
    TargetGroup  = module.alb.alb_target_group_names[0]
    LoadBalancer = module.alb.lb_arn_suffix
  }

  alarm_description = "ALB latency above 2 seconds for 10 minutes"
  alarm_actions     = [module.backend_sns_alerts.sns_topic_alerts_arn]
}