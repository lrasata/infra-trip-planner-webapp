module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "vpc-trip-design"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true # allow ECS tasks to pull images from ECR/Docker Hub and install updates
  single_nat_gateway = true
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"

  name               = "alb-trip-design"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.sg_alb.id]

  target_groups = [
    {
      name_prefix      = "tg-"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "ip"
      health_check = {
        path                = "/actuator/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200-399"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  ]

  http_tcp_listeners = [
    {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type               = "forward"
        target_group_index = 0
      }
    }
  ]
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "trip-design-rds-subnet-group"
  subnet_ids = [module.vpc.private_subnets[1], module.vpc.private_subnets[2]] # At least two subnets in different AZs
}
