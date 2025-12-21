data "aws_iam_policy_document" "cloudfront_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = [for path in var.paths : "${var.bucket_arn}/${path}"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.cloudfront_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = var.bucket_id
  policy = data.aws_iam_policy_document.cloudfront_policy.json
}