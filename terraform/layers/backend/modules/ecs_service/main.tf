resource "aws_ecs_service" "ecs_service" {
  name            = "${var.environment}-${var.app_id}-ecs-service"
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  desired_count   = 3 #  must be >= min_capacity of the scaling target
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.sg_ecs.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.alb_target_group_arns[0] # TODO Check this !!!
    container_name   = "${var.environment}-${var.app_id}-container"
    container_port   = 8080
  }
  health_check_grace_period_seconds = 120
  tags = {
    Environment = var.environment
    App         = var.app_id
  }
}

resource "aws_security_group" "sg_ecs" {
  name        = "${var.environment}-ecs-sg"
  description = "Allow outbound for ECS tasks and ALB to access ECS Tasks"
  vpc_id      = var.vpc_id
  tags = {
    Environment = var.environment
    App         = var.app_id
  }

  # Allow traffic from the ALB on port 8080
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.sg_alb_id] # allow traffic from ALB
  }

  # Allow ECS tasks to reach out to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ecs_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.sg_rds_id
  source_security_group_id = aws_security_group.sg_ecs.id
}

# Create an Application Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_service_scaling_target" {
  max_capacity       = 5
  min_capacity       = 2
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Define a scaling policy based on CPU utilization
resource "aws_appautoscaling_policy" "ecs_service_cpu_policy" {
  name               = "${var.environment}-${var.app_id}-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 50.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}