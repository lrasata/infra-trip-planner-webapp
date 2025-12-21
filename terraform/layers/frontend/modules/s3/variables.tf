variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
}

variable "static_web_app_bucket_name" {
  description = "The name of the S3 bucket for the static web app"
  type        = string
}

