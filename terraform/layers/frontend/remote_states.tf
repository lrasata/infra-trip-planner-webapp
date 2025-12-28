data "terraform_remote_state" "backend" {
  backend = "s3"
  config = {
    bucket = "trip-planner-states"
    key    = "backend/${var.environment}/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket = "trip-planner-states"
    key    = "security/${var.environment}/terraform.tfstate"
    region = "eu-central-1"
  }
}