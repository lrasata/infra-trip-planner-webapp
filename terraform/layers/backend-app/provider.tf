terraform {
  /*cloud {
    organization = "lrasata"

    workspaces {
      project = "Infra Trip planner webapp"
      name = "infra-trip-planner-webapp"
    }
  }*/

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

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}