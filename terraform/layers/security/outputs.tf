output "datasource_username" {
  value     = local.datasource_username
  sensitive = true
}

output "datasource_password" {
  value     = local.datasource_password
  sensitive = true
}

output "locations_auth_secret" {
  value     = local.locations_auth_secret
  sensitive = true
}

output "file_upload_auth_secret" {
  value     = local.file_upload_auth_secret
  sensitive = true
}

output "secrets_arn" {
  value     = data.aws_secretsmanager_secret.app_secrets.arn
  sensitive = true
}