provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Lambda@Edge function for SPA fallback in CloudFront
# This function serves the SPA fallback page when a user navigates to a non-existent route
# In this case, it serves the index.html file from the S3 bucket for any route which is different from /api/* or /auth/*
data "archive_file" "lambda_edge_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/lambdas/spa_fallback"
  output_path = "${path.module}/spa_fallback.zip"
}

# Lambda@Edge SPA fallback
resource "aws_lambda_function" "spa_fallback" {
  provider      = aws.us_east_1 # Lambda@Edge must be in us-east-1
  filename      = data.archive_file.lambda_edge_zip.output_path
  function_name = "${var.environment}-${var.app_id}-spa-fallback"
  role          = aws_iam_role.lambda_edge_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  publish       = true
}

resource "aws_iam_role" "lambda_edge_role" {
  name = "${var.environment}-${var.app_id}-lambda-edge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_edge_basic" {
  role       = aws_iam_role.lambda_edge_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}