variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
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

variable "backend_certificate_arn" {
  description = "The ARN of the ACM certificate for the ALB HTTPS listener and API Gateway"
  type        = string
}

variable "blocked_bots_waf_cloudfront" {
  type    = list(string)
  default = ["Nikto", "SQLMap", "ZAP", "Hydra", "Masscan"]
}

variable "static_web_app_bucket_name" {
  description = "The name of the S3 bucket for the static web app"
  type        = string
  default     = "trip-planner-app-bucket"
}

#--------- Image upload -----------------------------------
variable "api_image_upload_domain_name" {
  description = "The domain name for the API to get pre-signed image upload URLs"
  type        = string
  default     = "api-image-upload.epic-trip-planner.com"
}

#------------ Api locations -----------------------------

variable "api_locations_domain_name" {
  description = "The domain name for the API locations"
  type        = string
  default     = "api-locations.epic-trip-planner.com"
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