module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  name   = "trip-design-ecs"

  cluster_name = "trip-design-cluster"

  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnets
  create_task_exec_iam_role = true #  Used by ECS/Fargate to pull images and sends logs
  create_task_iam_role      = true # IAM role that the ECS task assumes at runtime to interact with AWS services.

  task_cpu    = 512
  task_memory = 1024

  container_definitions = jsonencode([
    {
      name      = "trip-design-container"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        { name = "ENVIRONMENT", value = "production" },
        { name = "SPRING_DATASOURCE_URL", value = var.database_url },
        { name = "SPRING_DATASOURCE_USERNAME", value = var.database_username },
        { name = "SPRING_DATASOURCE_PASSWORD", value = var.database_password },
        { name = "JWT_SECRET_KEY", value = var.jwt_secret_key },
        { name = "ALLOWED_ORIGIN", value = var.allowed_origin },
        { name = "COOKIE_SECURE_ATTRIBUTE", value = var.cookie_secure_attribute },
        { name = "COOKIE_SAME_SITE", value = var.cookie_same_site },
        { name = "SUPER_ADMIN_FULLNAME", value = var.super_admin_fullname },
        { name = "SUPER_ADMIN_EMAIL", value = var.super_admin_email },
        { name = "SUPER_ADMIN_PASSWORD", value = var.super_admin_password }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/trip-design-app"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "spring_service" {
  name            = "trip-design-service"
  cluster         = module.ecs.cluster_id
  task_definition = module.ecs.task_definition_arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.spring_tg.arn
    container_name   = "trip-design-load-balancer"
    container_port   = 8080
  }
  depends_on = [aws_lb_listener.http]
}