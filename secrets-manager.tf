data "aws_secretsmanager_secret" "trip_design_secrets" {
  name = "${var.environment}/trip-planner-app/secrets"
}

data "aws_secretsmanager_secret_version" "trip_design_secrets_value" {
  secret_id = data.aws_secretsmanager_secret.trip_design_secrets.id
}

locals {
  datasource_username  = jsondecode(data.aws_secretsmanager_secret_version.trip_design_secrets_value.secret_string)["SPRING_DATASOURCE_USERNAME"]
  datasource_password  = jsondecode(data.aws_secretsmanager_secret_version.trip_design_secrets_value.secret_string)["SPRING_DATASOURCE_PASSWORD"]
  geo_db_rapid_api_key = jsondecode(data.aws_secretsmanager_secret_version.trip_design_secrets_value.secret_string)["GEO_DB_RAPID_API_KEY"]
  auth_secret          = jsondecode(data.aws_secretsmanager_secret_version.trip_design_secrets_value.secret_string)["CUSTOM_AUTH_SECRET"]
}

resource "aws_iam_policy" "secrets_access" {
  name = "${var.environment}-ecs-access-prod-trip-planner-secrets"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.environment}/trip-planner-app/secrets-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_secrets_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}