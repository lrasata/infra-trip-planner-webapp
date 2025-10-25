data "terraform_remote_state" "backend_app" {
  backend = "s3"
  config = {
    bucket = "trip-planner-states"
    key    = "backend-app/terraform.tfstate"
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