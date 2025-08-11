resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.environment}-${var.bucket_name}"
}

resource "aws_s3_bucket_website_configuration" "s3-bucket-website" {
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# this is the build directory for the static files - after running `npm run build`
# it should contain the static files to be uploaded to S3
resource "null_resource" "upload_static_files" {
  depends_on = [aws_s3_bucket.s3_bucket]

  provisioner "local-exec" {
    command = "aws s3 sync ./dist/ s3://${aws_s3_bucket.s3_bucket.bucket}"
  }
}

resource "aws_s3_bucket_policy" "s3-bucket-policy" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = data.aws_iam_policy_document.s3_policy.json
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_bucket.arn}/*"]

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

#  Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "s3-bucket" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "s3-bucket" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}