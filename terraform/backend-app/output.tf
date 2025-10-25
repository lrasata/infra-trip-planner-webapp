output "uploads_bucket_id" {
  value = module.image_uploader.uploads_bucket_id
}

output "uploads_bucket_regional_domain_name" {
  value = module.image_uploader.uploads_bucket_regional_domain_name
}

output "alb_lb_dns_name" {
  value = module.alb.lb_dns_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}