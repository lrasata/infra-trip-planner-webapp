variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "app_id" {
  description = "Name which identifies the deployed app"
  type        = string
}

variable "task_execution_role_arn" {
  type = string
}

variable "container_image" {
  description = "The Docker image (e.g. ECR URI)"
  type        = string
}

variable "allowed_origins" {
  description = "Allowed origins : list of domains which are explicitly permitted to access resources  in the context of Cross-Origin Resource Sharing (CORS)"
  type        = string
}

variable "cookie_secure_attribute" {
  description = "Cookie is visible for Http only"
  type        = bool
}

variable "cookie_same_site" {
  description = "Cookie same site"
  type        = string
}

variable "super_admin_fullname" {
  description = "Fullname of bootstrapped SuperAdmin user when app starts"
  type        = string
}

variable "dynamo_db_table_name" {
  type = string
}

variable "s3_bucket_id" {
  type = string
}

variable "db_instance_address" {
  type = string
}

variable "db_name" {
  type = string
}

variable "secrets_arn" {
  type = string
}
