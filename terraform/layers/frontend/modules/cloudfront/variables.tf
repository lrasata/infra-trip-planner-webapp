variable "static_web_app_bucket_regional_domain_name" {
  type = string
}

variable "uploads_bucket_regional_domain_name" {
  type = string
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
}

variable "app_id" {
  description = "Name which identifies the deployed app"
  type        = string
}

variable "alb_lb_dns_name" {
  type = string
}

variable "api_locations_domain_name" {
  description = "The domain name for the API locations"
  type        = string
}

variable "locations_auth_secret" {
  type      = string
  sensitive = true
}

variable "api_file_upload_domain_name" {
  description = "The domain name for the API to get pre-signed file upload URLs"
  type        = string
}

variable "file_upload_auth_secret" {
  type      = string
  sensitive = true
}

variable "cloudfront_domain_name" {
  description = "The domain name for CloudFront distribution"
  type        = string
  default     = "epic-trip-planner.com"
}

variable "cloudfront_certificate_arn" {
  description = "The ARN of the ACM certificate for CloudFront"
  type        = string
}

variable "cloudfront_waf_arn" {
  type = string
}

variable "spa_fallback_qualified_arn" {
  type = string
}