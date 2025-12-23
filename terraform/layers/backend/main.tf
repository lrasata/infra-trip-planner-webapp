module "ecs_cluster" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = "${var.environment}-${var.app_id}-ecs-cluster"

  default_capacity_provider_strategy = {}
}

# ECS - Task Execution Role
module "ecs_task_execution_role" {
  source = "./modules/ecs_task_execution_role"

  app_id      = var.app_id
  region      = var.region
  environment = var.environment
}

# ECS - Task Definition
module "ecs_task_definition" {
  source = "./modules/ecs_task_definition"


  allowed_origins         = var.allowed_origins
  app_id                  = var.app_id
  container_image         = var.container_image
  db_instance_address     = try(data.terraform_remote_state.database.outputs.db_instance_address, "db-instance-address-placeholder")
  db_name                 = try(data.terraform_remote_state.database.outputs.db_name, "db-name-placeholder")
  dynamo_db_table_name    = module.file_uploader.dynamo_db_table_name
  environment             = var.environment
  region                  = var.region
  s3_bucket_id            = module.file_uploader.uploads_bucket_id
  secrets_arn             = try(data.terraform_remote_state.database.outputs.secrets_arn, "secrets-arn-placeholder")
  super_admin_fullname    = var.super_admin_fullname
  task_execution_role_arn = module.ecs_task_execution_role.task_exec_role_arn
  cookie_same_site        = var.cookie_same_site
  cookie_secure_attribute = var.cookie_secure_attribute
}

# ALB
module "alb" {
  source = "./modules/alb"

  alb_domain_name         = var.alb_domain_name
  app_id                  = var.app_id
  backend_certificate_arn = var.backend_certificate_arn
  environment             = var.environment
  hosted_zone_id          = var.route53_zone_name
  public_subnets          = try(data.terraform_remote_state.networking.outputs.public_subnets, ["public-subnet-placeholder1", "public-subnet-placeholder2"])
  vpc_id                  = try(data.terraform_remote_state.networking.outputs.vpc_id, "vpc-id-placeholder")
}

# ECS Service
module "ecs_service" {
  source = "./modules/ecs_service"

  alb_target_group_arns = module.alb.alb_target_group_arns
  app_id                = var.app_id
  cluster_id            = module.ecs_cluster.cluster_id
  cluster_name          = module.ecs_cluster.cluster_name
  environment           = var.environment
  private_subnets       = try(data.terraform_remote_state.networking.outputs.private_subnets, ["private-subnet-placeholder1", "private-subnet-placeholder2"])
  sg_alb_id             = module.alb.sg_alb_id
  sg_rds_id             = try(data.terraform_remote_state.database.outputs.rds_sg.id, "sg-rds-id-placeholder")
  task_definition_arn   = module.ecs_task_definition.task_definition_arn
  vpc_id                = try(data.terraform_remote_state.networking.outputs.vpc_id, "vpc-id-placeholder")
}

# File uploader
module "file_uploader" {
  source = "git::https://github.com/lrasata/infra-file-uploader//terraform/modules/file_uploader?ref=v1.6.1"

  region                                        = var.region
  environment                                   = var.environment
  api_file_upload_domain_name                   = var.api_file_upload_domain_name
  backend_certificate_arn                       = var.backend_certificate_arn
  uploads_bucket_name                           = var.uploads_bucket_name
  enable_transfer_acceleration                  = var.enable_transfer_acceleration
  lambda_upload_presigned_url_expiration_time_s = var.lambda_upload_presigned_url_expiration_time_s
  lambda_memory_size_mb                         = var.lambda_memory_size_mb
  bucket_av_sns_findings_topic_name             = var.bucketav_sns_findings_topic_name
  notification_email                            = var.notification_email
  route53_zone_name                             = var.route53_zone_name
  secret_store_name                             = var.secret_store_name
  use_bucket_av                                 = var.use_bucketav
}

module "image_moderator" {
  source = "git::https://github.com/lrasata/infra-s3-image-moderator//modules/s3_image_moderator?ref=v1.1.0"

  region                    = var.region
  environment               = var.environment
  s3_src_bucket_name        = module.file_uploader.uploads_bucket_id
  s3_src_bucket_arn         = module.file_uploader.uploads_bucket_arn
  s3_quarantine_bucket_name = var.quarantine_bucket_name
  admin_email               = var.notification_email
}