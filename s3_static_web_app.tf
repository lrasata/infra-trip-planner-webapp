resource "aws_s3_bucket" "static_web_app_bucket" {
  bucket = "${var.environment}-${var.static_web_app_bucket_name}"
  region = var.region
}

# this is the build directory for the static files - after running `npm run build`
# it should contain the static files to be uploaded to S3
resource "null_resource" "upload_static_files" {
  depends_on = [aws_s3_bucket.static_web_app_bucket]

  provisioner "local-exec" {
    command = "aws s3 sync ./dist/ s3://${aws_s3_bucket.static_web_app_bucket.bucket}"
  }
}

data "aws_iam_policy_document" "static_web_app_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_web_app_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "static_web_app_bucket_policy" {
  bucket = aws_s3_bucket.static_web_app_bucket.id
  policy = data.aws_iam_policy_document.static_web_app_policy_document.json
}

#  Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "s3-bucket" {
  bucket                  = aws_s3_bucket.static_web_app_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}