output "datasource_username" {
  value = local.datasource_username
}

output "datasource_password" {
  value = local.datasource_password
}

output "locations_auth_secret" {
  value = local.locations_auth_secret
}

output "img_upload_auth_secret" {
  value = local.img_upload_auth_secret
}

output "secrets_arn" {
  value = data.aws_secretsmanager_secret_version.trip_design_secrets_value.arn
}