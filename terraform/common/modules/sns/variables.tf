variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
}

variable "app_id" {
  description = "Application identifier for tagging resources"
  type        = string
}

variable "service_name" {
  description = "Service name for tagging resources"
  type        = string
}


variable "notification_email" {
  description = "Email address for notifications"
  type        = string
}