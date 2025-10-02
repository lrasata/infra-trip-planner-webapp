# Bucket policy allowing CloudFront OAC access
resource "aws_s3_bucket_policy" "uploads_bucket_policy" {
  bucket = module.image_uploader.uploads_bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = [
          "arn:aws:s3:::${module.image_uploader.uploads_bucket_id}/uploads/*",
          "arn:aws:s3:::${module.image_uploader.uploads_bucket_id}/thumbnails/*"
        ]
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}