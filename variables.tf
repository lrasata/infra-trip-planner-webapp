variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "container_image" {
  description = "The Docker image (e.g. ECR URI)"
  type        = string
}

variable "database_name" {
  description = "database name"
  type        = string
  default     = "tripdb"
}

variable "allowed_origins" {
  description = "Allowed origins : list of domains which are explicitly permitted to access resources  in the context of Cross-Origin Resource Sharing (CORS)"
  type        = string
}

variable "cookie_secure_attribute" {
  description = "Cookie is visible for Http only"
  type        = bool
  default     = true
}

variable "cookie_same_site" {
  description = "Cookie same site"
  type        = string
  default     = "Lax"
}

variable "super_admin_fullname" {
  description = "Fullname of bootstrapped SuperAdmin user when app starts"
  type        = string
}

variable "API_CITIES_GEO_DB_URL" {
  description = "The URL for the Cities GeoDB API"
  type        = string
}

variable "API_COUNTRIES_GEO_DB_URL" {
  description = "The URL for the Countries GeoDB API"
  type        = string
}

variable "GEO_DB_RAPID_API_HOST" {
  description = "The host for the GeoDB Rapid API"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket for the React app"
  type        = string
  default     = "trip-planner-app-bucket"
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, prod)"
  type        = string
  default     = "prod"
}

variable "backend_certificate_arn" {
  description = "The ARN of the ACM certificate for the ALB HTTPS listener and API Gateway"
  type        = string
}

variable "cloudfront_certificate_arn" {
  description = "The ARN of the ACM certificate for CloudFront"
  type        = string
}

variable "api_locations_domain_name" {
  description = "The domain name for the API locations"
  type        = string
  default     = "api-locations.epic-trip-planner.com"
}

variable "alb_domain_name" {
  description = "The domain name for the API"
  type        = string
  default     = "alb.epic-trip-planner.com"
}

variable "cloudfront_domain_name" {
  description = "The domain name for CloudFront distribution"
  type        = string
  default     = "epic-trip-planner.com"
}

variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for example.com"
  type        = string
}

variable "blocked_bots_waf_cloudfront" {
  type    = list(string)
  default = ["Nikto", "SQLMap", "ZAP", "Hydra", "Masscan"]
}

variable "blocked_bots_waf_alb" {
  type = list(string)
  default = [
    "AhrefsBot",
    "SemrushBot",
    "MJ12bot",
    "DotBot"
  ]
}
