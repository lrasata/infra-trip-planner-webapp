output "uploads_bucket_id" {
  value = module.file_uploader.uploads_bucket_id
}

output "uploads_bucket_arn" {
  value = module.file_uploader.uploads_bucket_arn
}

output "uploads_bucket_regional_domain_name" {
  value = module.file_uploader.uploads_bucket_regional_domain_name
}

output "alb_lb_dns_name" {
  value = module.alb.lb_dns_name
}