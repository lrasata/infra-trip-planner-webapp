# ============================================================================
# Logging target bucket - S3 access logs
# ============================================================================
resource "aws_s3_bucket" "log_target" {
  bucket = "${var.environment}-${var.app_id}-s3-access-logs"
}

resource "aws_s3_bucket_ownership_controls" "log_target_ownership" {
  bucket = aws_s3_bucket.log_target.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "log_target_versioning" {
  bucket = aws_s3_bucket.log_target.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "log_target_block" {
  bucket = aws_s3_bucket.log_target.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "log_target_policy" {
  bucket = aws_s3_bucket.log_target.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "logging.s3.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.log_target.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_logging" "s3_bucket_logging" {
  bucket        = aws_s3_bucket.s3_bucket.id
  target_bucket = aws_s3_bucket.log_target.id
  target_prefix = "${var.environment}-${var.app_id}-s3-bucket-access-logs/"

  depends_on = [
    aws_s3_bucket_policy.log_target_policy,
    aws_s3_bucket_ownership_controls.log_target_ownership
  ]
}