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

variable "azs" {
  description = "List of availability zones in the region"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnets_ips" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets_ips" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}