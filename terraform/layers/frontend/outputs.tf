output "cloudfront_domain_name" {
  value = module.cloudfront.cloudfront_domain_name
}

output "cloudfront_id" {
  value = module.cloudfront.cloudfront_id
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "api_locations_domain_name" {
  value = var.api_locations_domain_name
}