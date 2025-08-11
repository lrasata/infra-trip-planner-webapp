module "ecs_cluster" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = "ecs-cluster-trip-design"

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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_secrets_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_cloudwatch_log_group" "ecs_trip_design" {
  name              = "/ecs/trip-design-app"
  retention_in_days = 7
}

# --- ECS Task Definition ---
resource "aws_ecs_task_definition" "task-trip-design" {
  family                   = "task-trip-design"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "trip-design-container",
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
        { name = "ALLOWED_ORIGIN", value = var.allowed_origin },
        { name = "COOKIE_SECURE_ATTRIBUTE", value = tostring(var.cookie_secure_attribute) }, # for boolean, must explicitly convert the boolean to a string
        { name = "COOKIE_SAME_SITE", value = var.cookie_same_site },
        { name = "SUPER_ADMIN_FULLNAME", value = var.super_admin_fullname }
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
          awslogs-group         = aws_cloudwatch_log_group.ecs_trip_design.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ecs_service_trip_design" {
  name            = "ecs-service-trip-design"
  cluster         = module.ecs_cluster.cluster_id
  task_definition = aws_ecs_task_definition.task-trip-design.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [module.vpc.private_subnets[0]]
    security_groups  = [aws_security_group.sg_ecs.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "trip-design-container"
    container_port   = 8080
  }

  depends_on = [
    module.alb,
    module.db
  ] # ensures ALB and DB are created before ECS
}

resource "aws_security_group" "sg_ecs" {
  name        = "ecs-sg"
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