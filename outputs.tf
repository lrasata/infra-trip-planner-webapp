output "alb_dns_name" {
  description = "ALB DNS name to access app running behind LB"
  value       = module.alb.lb_dns_name
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution for the NLB"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket where static files are hosted"
  value = aws_s3_bucket.s3_bucket.bucket
}