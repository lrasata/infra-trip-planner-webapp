data "terraform_remote_state" "backend_app" {
  backend = "s3"
  config = {
    bucket = "trip-planner-states"
    key    = "backend-app/terraform.tfstate"
    region = "eu-central-1"
  }
}