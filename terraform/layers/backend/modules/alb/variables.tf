variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
}

variable "app_id" {
  description = "Name which identifies the deployed app"
  type        = string
}

variable "alb_domain_name" {
  description = "The domain name for the API"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for example.com"
  type        = string
}

variable "backend_certificate_arn" {
  description = "The ARN of the ACM certificate for the ALB HTTPS listener and API Gateway"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}