variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "database_name" {
  description = "database name"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "app_id" {
  description = "Name which identifies the deployed app"
  type        = string
}

variable "notification_email" {
  description = "Email address for notifications"
  type        = string
}

variable "restore_db_snapshot_id" {
  description = "Optional snapshot ID to restore from (leave empty on first deploy)"
  type        = string
  default     = ""
}
