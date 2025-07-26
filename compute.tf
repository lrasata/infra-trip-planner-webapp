module "ecs_cluster" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = "ecs-cluster-trip-design"

  default_capacity_provider_strategy = {}
}

module "ecs_task_execution_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.34.0"

  create_role           = true # required
  role_name             = "ecsTaskExecutionRole"
  trusted_role_services = ["ecs-tasks.amazonaws.com"]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ]
}

# --- ECS Task Definition ---
resource "aws_ecs_task_definition" "task-trip-design" {
  family                   = "task-trip-design"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
  task_role_arn            = module.ecs_task_execution_role.iam_role_arn

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
          awslogs-group         = "/ecs/trip-design-app"
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
}