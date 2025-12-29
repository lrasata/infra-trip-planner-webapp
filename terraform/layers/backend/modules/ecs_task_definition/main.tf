####################################################################################################################
# ECS Task Definition
####################################################################################################################
locals {
  container_environment = [
    { name = "ENVIRONMENT", value = var.environment },
    { name = "SPRING_DATASOURCE_URL", value = "jdbc:postgresql://${var.db_instance_address}:5432/${var.db_name}" },
    { name = "ALLOWED_ORIGINS", value = var.allowed_origins },
    { name = "COOKIE_SECURE_ATTRIBUTE", value = tostring(var.cookie_secure_attribute) },
    { name = "COOKIE_SAME_SITE", value = var.cookie_same_site },
    { name = "SUPER_ADMIN_FULLNAME", value = var.super_admin_fullname },
    { name = "AWS_REGION", value = var.region },
    { name = "DYNAMODB_TABLE_NAME", value = var.dynamo_db_table_name },
    { name = "S3_BUCKET_NAME", value = var.s3_bucket_id }
  ]

  container_secrets = [
    "SPRING_DATASOURCE_USERNAME",
    "SPRING_DATASOURCE_PASSWORD",
    "JWT_SECRET_KEY",
    "SUPER_ADMIN_EMAIL",
    "SUPER_ADMIN_PASSWORD"
  ]
}

resource "aws_cloudwatch_log_group" "ecs_task_log_group" {
  name              = "${var.environment}/${var.app_id}/ecs-task"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${var.environment}-${var.app_id}-ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.environment}-${var.app_id}-container"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = local.container_environment
      secrets = [
        for key in local.container_secrets : {
          name      = key
          valueFrom = "${var.secrets_arn}:${key}::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_task_log_group.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}