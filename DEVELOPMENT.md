# Recommended Deployment Method

It is **recommended** to use the CI/CD pipeline for deploying infrastructure to different  environments. This ensures consistency, automation, and reduces manual errors.

- For **ephemeral** environments (PR-based): Use the `apply-to-ephemeral-env.yml` workflow, triggered on PR approval.
- For **staging**: Use the `apply-to-staging-env.yml` workflow, triggered manually by selecting the environment.

The workflows handle Terraform initialization, planning, and application automatically. Below is a list of all TF_VAR environment variables used in the CI/CD pipeline, along with their descriptions, for reference and troubleshooting:

## TF_VAR Variables Used in CI/CD Pipeline

| Variable | Description |
|----------|-------------|
| TF_VAR_region | AWS region (e.g., eu-central-1) |
| TF_VAR_app_id | Application identifier (e.g., trip-planner-app) |
| TF_VAR_environment | Deployment environment (staging or production) |
| TF_VAR_azs | List of availability zones (e.g., ["eu-central-1a", "eu-central-1b", "eu-central-1c"]) |
| TF_VAR_vpc_cidr | VPC CIDR block (e.g., 10.42.0.0/16) |
| TF_VAR_public_subnets_ips | List of public subnet CIDR blocks (e.g., ["10.42.101.0/24","10.42.102.0/24","10.42.103.0/24"]) |
| TF_VAR_private_subnets_ips | List of private subnet CIDR blocks (e.g., ["10.42.1.0/24","10.42.2.0/24","10.42.3.0/24"]) |
| TF_VAR_notification_email | Email for notifications (from secrets) |
| TF_VAR_alb_domain_name | ALB domain name (e.g., staging-alb.epic-trip-planner.com) |
| TF_VAR_route53_zone_name | Route53 hosted zone name (e.g., epic-trip-planner.com) |
| TF_VAR_hosted_zone_id | Route53 hosted zone ID (from secrets) |
| TF_VAR_container_image | Docker container image (e.g., lrasata/trip-planner-backend-app:1.1.0) |
| TF_VAR_allowed_origins | Allowed CORS origins (e.g., https://staging.epic-trip-planner.com) |
| TF_VAR_api_file_upload_domain_name | API domain for file uploads (e.g., staging-file-upload-api.epic-trip-planner.com) |
| TF_VAR_backend_certificate_arn | ARN of the backend certificate (from secrets) |
| TF_VAR_use_bucketav | Whether to use bucket antivirus (default: false) |
| TF_VAR_bucketav_sns_findings_topic_name | SNS topic for bucket AV findings ("" if none) |
| TF_VAR_uploads_bucket_name | S3 bucket for uploads (e.g., file-uploads-bucket-staging) |
| TF_VAR_enable_transfer_acceleration | Enable S3 transfer acceleration (default: true) |
| TF_VAR_secret_store_name | Name of the secret store (from secrets) |
| TF_VAR_cloudfront_domain_name | CloudFront domain name (e.g., staging.epic-trip-planner.com) |
| TF_VAR_cloudfront_certificate_arn | ARN of the CloudFront certificate (from secrets) |
| TF_VAR_static_web_app_bucket_name | S3 bucket for static web app (e.g., static-web-app-bucket-staging) |
| TF_VAR_api_locations_domain_name | API domain for locations (e.g., staging-api-locations.epic-trip-planner.com) |
| TF_VAR_API_CITIES_GEO_DB_URL | URL for cities GeoDB API (from secrets) |
| TF_VAR_API_COUNTRIES_GEO_DB_URL | URL for countries GeoDB API (from secrets) |
| TF_VAR_GEO_DB_RAPID_API_HOST | Host for GeoDB RapidAPI (from secrets) |

### Instruction to restore database from snapshot

Recreate DB from snapshot, by providing `restore_snapshot_id=<your-snapshot-id>` in `../common/staging.tfvars` and run: 

````text
terraform apply -var-file="../common/staging.tfvars" -compact-warnings -auto-approve
````

### Backup and restore DynamoDB table

#### Create a backup of DynamoDB table

````bash
./scripts/backup_dynamodb.sh staging-files-metadata backup-staging-files-metadata-20251101-1820
````

### Restore a backup of DynamoDB table

````bash
./scripts/restore_dynamodb_backup.sh staging-files-metadata staging-temp-table arn:aws:dynamodb:eu-central-1:<id>:table/staging-files-metadata/backup/<id>
````