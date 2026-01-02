####################################################################################################################
# ECS - Task Execution Role Configuration
####################################################################################################################
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.environment}-${var.app_id}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}


data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "secrets_kms_access" {
  name = "${var.environment}-${var.app_id}-secrets-and-kms-iam-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.environment}/${var.app_id}/secrets-*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource = "*"
      }
    ]
  })
}

locals {
  ecs_execution_role_policies_map = {
    ecs_execution = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    s3_full       = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    dynamo_read   = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
    secrets       = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role" {
  for_each   = local.ecs_execution_role_policies_map
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = each.value
}

# Attach dynamic separately
resource "aws_iam_role_policy_attachment" "ecs_execution_role_dynamic" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets_kms_access.arn
}