output "alb_dns_name" {
  description = "ALB DNS name to access app running behind LB"
  value = module.alb.lb_dns_name
}
