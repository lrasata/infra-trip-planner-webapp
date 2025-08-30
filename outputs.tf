output "api_gateway_invoke_url" {
  description = "Public URL for invoking the API Gateway"
  value       = "https://${var.api_locations_domain_name}/locations"
}

output "alb_dns_name" {
  description = "ALB URL for the backend API"
  value       = "https://${var.alb_domain_name}"
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.cdn.aliases
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket where static files are hosted"
  value       = aws_s3_bucket.s3_bucket.bucket
}