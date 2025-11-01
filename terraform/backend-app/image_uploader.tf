module "image_uploader" {
  source = "git::https://github.com/lrasata/infra-image-uploader//modules/image_uploader?ref=v1.2.1"

  lambda_process_uploaded_file_dir = "./lambda_process_uploaded_file_build"

  region                                        = var.region
  environment                                   = var.environment
  api_image_upload_domain_name                  = var.api_image_upload_domain_name
  backend_certificate_arn                       = var.backend_certificate_arn
  uploads_bucket_name                           = var.uploads_bucket_name
  enable_transfer_acceleration                  = var.enable_transfer_acceleration
  lambda_upload_presigned_url_expiration_time_s = var.lambda_upload_presigned_url_expiration_time_s
  use_bucketav                                  = var.use_bucketav
  bucketav_sns_findings_topic_name              = var.bucketav_sns_findings_topic_name
  lambda_memory_size_mb                         = var.lambda_memory_size_mb
  dynamodb_partition_key                        = var.dynamodb_partition_key
  dynamodb_sort_key                             = var.dynamodb_sort_key
}