output "alb_target_group_arns" {
  value = module.terraform_aws_alb.target_group_arns
}

output "alb_target_group_names" {
  value = module.terraform_aws_alb.target_group_names
}

output "lb_arn_suffix" {
  value = module.terraform_aws_alb.lb_arn_suffix
}

output "lb_arn" {
  value = module.terraform_aws_alb.lb_arn
}

output "lb_dns_name" {
  value = module.terraform_aws_alb.lb_dns_name
}

output "sg_alb_id" {
  value = aws_security_group.sg_alb.id
}