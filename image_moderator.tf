module "image_moderator" {
  source = "git::https://github.com/lrasata/infra-s3-image-moderator//modules/s3_image_moderator?ref=v1.0.0"

  region                    = var.region
  environment               = var.environment
  s3_src_bucket_name        = module.image_uploader.uploads_bucket_id
  s3_src_bucket_arn         = module.image_uploader.uploads_bucket_arn
  s3_quarantine_bucket_name = var.quarantine_bucket_name
  admin_email               = var.notification_email
}