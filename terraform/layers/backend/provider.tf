terraform {
  backend "s3" {
    bucket = "trip-planner-states"
    key    = "backend-app/terraform.tfstate"
    region = "eu-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4"
    }
  }

  required_version = ">= 1.3"
}

provider "aws" {
  region = var.region
}