data "aws_secretsmanager_secret" "trip_design_secrets" {
  name = "${var.environment}/trip-planner-app/secrets"
}

data "aws_secretsmanager_secret_version" "trip_design_secrets_value" {
  secret_id = data.aws_secretsmanager_secret.trip_design_secrets.id
}

locals {
  datasource_username    = jsondecode(data.aws_secretsmanager_secret_version.trip_design_secrets_value.secret_string)["SPRING_DATASOURCE_USERNAME"]
  datasource_password    = jsondecode(data.aws_secretsmanager_secret_version.trip_design_secrets_value.secret_string)["SPRING_DATASOURCE_PASSWORD"]
  locations_auth_secret  = jsondecode(data.aws_secretsmanager_secret_version.trip_design_secrets_value.secret_string)["API_GW_LOCATIONS_AUTH_SECRET"]
  img_upload_auth_secret = jsondecode(data.aws_secretsmanager_secret_version.trip_design_secrets_value.secret_string)["API_GW_IMG_UPLOAD_AUTH_SECRET"]
}