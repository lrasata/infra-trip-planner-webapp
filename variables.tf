variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "container_image" {
  description = "The Docker image (e.g. ECR URI)"
  type        = string
}

variable "database_url" {
  description = "DB URL, e.g., postgres://user:pass@host:5432/db"
  type        = string
}

variable "database_username" {
  description = "database username"
  type = string
  default = "postgres"
}

variable "database_password" {
  description = "database password"
  type = string
  sensitive = true
}

variable "jwt_secret_key" {
  description = "Secret used for JWT"
  type        = string
  sensitive = true
}

variable "allowed_origin" {
  description = "Allowed origin : domain that is explicitly permitted to access resources  in the context of Cross-Origin Resource Sharing (CORS)"
  type        = string # TODO this would be setup to the frontend ip or domain...
}

variable "cookie_secure_attribute" {
  description = "Cookie is visible for Http only"
  type        = bool
  default = true
}

variable "cookie_same_site" {
  description = "Cookie same site"
  type = string
  default = "Lax"
}

variable "super_admin_fullname" {
  description = "Fullname of bootstrapped SuperAdmin user when app starts"
  type = string
  default = "admin"
}

variable "super_admin_email" {
  description = "Email of bootstrapped SuperAdmin user when app starts"
  type = string
  default = "admin@admin.com"
}

variable "super_admin_password" {
  description = "Password of bootstrapped SuperAdmin user when app starts"
  type = string
  sensitive = true
}

