resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.environment}-${var.app_id}-${var.static_web_app_bucket_name}"
  tags = {
    Environment = var.environment
    App         = var.app_id
  }

}

# Enable server-side encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "uploads_encryption" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_cmk.arn
    }
  }
}

#  Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}