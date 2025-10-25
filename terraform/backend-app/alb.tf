# -------------------------
# ALB : Application Load Balancer - exposes the backend service
# This module creates an Application Load Balancer (ALB) with a target group and listener
# -------------------------
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"

  name               = "${var.environment}-alb-trip-planner"
  load_balancer_type = "application"
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  subnets            = data.terraform_remote_state.networking.outputs.public_subnets
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
        unhealthy_threshold = 10
      }
    }
  ]

  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-2016-08"
      certificate_arn = var.backend_certificate_arn

      default_action = {
        type               = "forward"
        target_group_index = 0
      }
    }
  ]

}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = module.alb.lb_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_security_group" "sg_alb" {
  name        = "${var.environment}-alb-sg"
  description = "Allow HTTPS"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ROUTE 53 ALIAS RECORD
resource "aws_route53_record" "alb_domain" {
  zone_id = var.hosted_zone_id
  name    = var.alb_domain_name
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}
