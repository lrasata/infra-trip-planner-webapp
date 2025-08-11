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

variable "allowed_origin" {
  description = "Allowed origin : domain that is explicitly permitted to access resources  in the context of Cross-Origin Resource Sharing (CORS)"
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

variable "bucket_name" {
  description = "The name of the S3 bucket for the React app"
  type        = string
  default     = "trip-design-app-bucket"
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, prod)"
  type        = string
  default     = "prod"
}

variable "alb_certificate_arn" {
  description = "The ARN of the ACM certificate for the ALB HTTPS listener"
  type        = string
}

variable "cloudfront_certificate_arn" {
    description = "The ARN of the ACM certificate for CloudFront"
    type        = string
}
