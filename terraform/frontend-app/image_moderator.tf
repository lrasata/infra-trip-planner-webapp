module "image_moderator" {
  source = "git::https://github.com/lrasata/infra-s3-image-moderator//modules/s3_image_moderator?ref=v1.1.0"

  region                    = var.region
  environment               = var.environment
  s3_src_bucket_name        = data.terraform_remote_state.backend_app.outputs.uploads_bucket_id
  s3_src_bucket_arn         = data.terraform_remote_state.backend_app.outputs.uploads_bucket_arn
  s3_quarantine_bucket_name = var.quarantine_bucket_name
  admin_email               = var.notification_email
}