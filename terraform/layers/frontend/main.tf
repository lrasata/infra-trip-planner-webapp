module "s3" {
  source = "./modules/s3"

  environment                = var.environment
  static_web_app_bucket_name = var.static_web_app_bucket_name
}

module "spa_fallback" {
  source = "./modules/lambda_at_edge"

  app_id      = var.app_id
  environment = var.environment
}

module "cloudfront" {
  source = "./modules/cloudfront"

  alb_lb_dns_name                            = try(data.terraform_remote_state.backend_app.outputs.alb_lb_dns_name, "alb-lb-dns-name-placeholder")
  api_file_upload_domain_name                = var.api_file_upload_domain_name
  api_locations_domain_name                  = var.api_locations_domain_name
  app_id                                     = var.app_id
  cloudfront_certificate_arn                 = var.cloudfront_certificate_arn
  cloudfront_waf_arn                         = aws_wafv2_web_acl.cloudfront_waf.arn
  environment                                = var.environment
  file_upload_auth_secret                    = try(data.terraform_remote_state.backend_app.outputs.file_upload_auth_secret, "file-upload-auth-secret-placeholder")
  locations_auth_secret                      = try(data.terraform_remote_state.backend_app.outputs.locations_auth_secret, "locations-auth-secret-placeholder")
  spa_fallback_qualified_arn                 = module.spa_fallback.lambda_at_edge_arn
  static_web_app_bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  uploads_bucket_regional_domain_name        = try(data.terraform_remote_state.backend_app.outputs.uploads_bucket_regional_domain_name, "uploads-regional-domain-name-placeholder")
}

# For the static web app bucket
module "static_web_app_policy" {
  source = "./modules/cloudfront_s3_bucket_policy"

  bucket_id      = module.s3.bucket_id
  bucket_arn     = module.s3.bucket_arn
  cloudfront_arn = module.cloudfront.cloudfront_arn
  paths          = ["*"]
}

# For the uploads bucket
module "uploads_bucket_policy" {
  source = "./modules/cloudfront_s3_bucket_policy"

  bucket_id      = try(data.terraform_remote_state.backend_app.outputs.uploads_bucket_id, "uploads-bucket-id-placeholder")
  bucket_arn     = try(data.terraform_remote_state.backend_app.outputs.uploads_bucket_arn, "uploads-bucket-arn-placeholder")
  cloudfront_arn = module.cloudfront.cloudfront_arn
  paths          = ["uploads/*", "thumbnails/*"]
}

# route 53
module "route53" {
  source = "./modules/route53"


  cdn_domain_name        = module.cloudfront.cloudfront_domain_name
  cdn_hosted_zone_id     = module.cloudfront.cloudfront_hosted_zone_id
  cloudfront_domain_name = var.cloudfront_domain_name
}

module "locations_api" {
  source = "git::https://github.com/lrasata/locations-api.git//modules/locations_api?ref=v1.0.1"

  region                    = var.region
  environment               = var.environment
  api_locations_domain_name = var.api_locations_domain_name
  backend_certificate_arn   = var.backend_certificate_arn
  API_CITIES_GEO_DB_URL     = var.API_CITIES_GEO_DB_URL
  API_COUNTRIES_GEO_DB_URL  = var.API_COUNTRIES_GEO_DB_URL
  GEO_DB_RAPID_API_HOST     = var.GEO_DB_RAPID_API_HOST
  route_53_zone_id          = module.route53.route53_zone_id
  sns_topic_alerts_arn      = module.frontend_sns_alerts.sns_topic_alerts_arn
}
