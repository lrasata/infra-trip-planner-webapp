data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "trip-planner-states"
    key    = "networking/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket = "trip-planner-states"
    key    = "security/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "database" {
  backend = "s3"
  config = {
    bucket = "trip-planner-states"
    key    = "database/terraform.tfstate"
    region = "eu-central-1"
  }
}