data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.environment}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_secrets_access.arn
}

resource "aws_lambda_function" "locations_api" {
  function_name = "${var.environment}-location-api-lambda"
  runtime       = "nodejs20.x"
  handler       = "index.handler" # file.function exported

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      API_CITIES_GEO_DB_URL    = var.API_CITIES_GEO_DB_URL
      API_COUNTRIES_GEO_DB_URL = var.API_COUNTRIES_GEO_DB_URL
      GEO_DB_RAPID_API_HOST    = var.GEO_DB_RAPID_API_HOST
      GEO_DB_RAPID_API_KEY     = local.geo_db_rapid_api_key
      CUSTOM_AUTH_SECRET       = local.auth_secret
    }
  }

  depends_on = [data.archive_file.lambda_zip, aws_iam_role.lambda_exec]
}

resource "aws_iam_policy" "lambda_secrets_access" {
  name        = "${var.environment}-lambda-secretsmanager-access"
  description = "Allow Lambda to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = data.aws_secretsmanager_secret.trip_design_secrets.arn
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
