module "ecs_cluster" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = "${var.environment}-ecs-cluster-trip-design"

  default_capacity_provider_strategy = {}
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


# Attach AmazonS3FullAccess managed policy
resource "aws_iam_role_policy_attachment" "ecs_task_s3_full_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attach AmazonDynamoDBReadOnlyAccess managed policy
resource "aws_iam_role_policy_attachment" "ecs_task_dynamodb_readonly" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_secrets_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_cloudwatch_log_group" "ecs_trip_planner" {
  name              = "${var.environment}/ecs/trip-planner-app"
  retention_in_days = 7
}

# --- ECS Task Definition ---
resource "aws_ecs_task_definition" "task-trip-planner" {
  family                   = "${var.environment}-task-trip-planner"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.environment}-trip-planner-container",
      image     = var.container_image,
      essential = true,
      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080,
        }
      ],
      environment = [
        { name = "ENVIRONMENT", value = "production" },
        { name = "SPRING_DATASOURCE_URL", value = "jdbc:postgresql://${module.db.db_instance_address}:5432/${var.database_name}" },
        { name = "ALLOWED_ORIGINS", value = var.allowed_origins },
        { name = "COOKIE_SECURE_ATTRIBUTE", value = tostring(var.cookie_secure_attribute) }, # for boolean, must explicitly convert the boolean to a string
        { name = "COOKIE_SAME_SITE", value = var.cookie_same_site },
        { name = "SUPER_ADMIN_FULLNAME", value = var.super_admin_fullname },
        { name = "AWS_REGION", value = var.region },
        { name = "DYNAMODB_TABLE_NAME", value = module.image_uploader.dynamo_db_table_name },
        { name = "S3_BUCKET_NAME", value = module.image_uploader.uploads_bucket_id }
      ],
      secrets = [
        {
          name      = "SPRING_DATASOURCE_USERNAME"
          valueFrom = "${data.aws_secretsmanager_secret.trip_design_secrets.arn}:SPRING_DATASOURCE_USERNAME::"
        },
        {
          name      = "SPRING_DATASOURCE_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret.trip_design_secrets.arn}:SPRING_DATASOURCE_PASSWORD::"
        },
        {
          name      = "JWT_SECRET_KEY"
          valueFrom = "${data.aws_secretsmanager_secret.trip_design_secrets.arn}:JWT_SECRET_KEY::"
        },
        {
          name      = "SUPER_ADMIN_EMAIL"
          valueFrom = "${data.aws_secretsmanager_secret.trip_design_secrets.arn}:SUPER_ADMIN_EMAIL::"
        },
        {
          name      = "SUPER_ADMIN_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret.trip_design_secrets.arn}:SUPER_ADMIN_PASSWORD::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_trip_planner.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ecs_service_trip_design" {
  name            = "${var.environment}-ecs-service-trip-planner"
  cluster         = module.ecs_cluster.cluster_id
  task_definition = aws_ecs_task_definition.task-trip-planner.arn
  desired_count   = 3 #  must be >= min_capacity of the scaling target
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.sg_ecs.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "${var.environment}-trip-planner-container"
    container_port   = 8080
  }
  health_check_grace_period_seconds = 120


  depends_on = [
    module.alb,
    module.db
  ] # ensures ALB and DB are created before ECS
}

resource "aws_security_group" "sg_ecs" {
  name        = "${var.environment}-ecs-sg"
  description = "Allow outbound for ECS tasks and ALB to access ECS Tasks"
  vpc_id      = module.vpc.vpc_id

  # Allow traffic from the ALB on port 8080
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id] # allow traffic from ALB
  }

  # Allow ECS tasks to reach out to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an Application Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_service_scaling_target" {
  max_capacity       = 5
  min_capacity       = 2
  resource_id        = "service/${module.ecs_cluster.cluster_name}/${aws_ecs_service.ecs_service_trip_design.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Define a scaling policy based on CPU utilization
resource "aws_appautoscaling_policy" "ecs_service_cpu_policy" {
  name               = "${var.environment}-cpu-scaling-policy"
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