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