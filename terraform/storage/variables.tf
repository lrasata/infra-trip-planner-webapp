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

variable "quarantine_bucket_name" {
  description = "S3 quarantine bucket name for flagged content"
  type        = string
  default     = "quarantine-bucket"
}

variable "notification_email" {
  description = "Email address for notifications"
  type        = string
}