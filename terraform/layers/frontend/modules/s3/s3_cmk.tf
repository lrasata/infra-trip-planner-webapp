data "aws_caller_identity" "current" {}

locals {
  github_roles = [
    "arn:aws:iam::387836084035:role/githubTripPlannerInfraManager",
    "arn:aws:iam::387836084035:role/githubTripWebPlannerApp"
  ]
}

resource "aws_kms_key" "s3_cmk" {
  description         = "CMK for S3 and access logs"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = flatten([
      [
        # Root account full access
        {
          Sid       = "AllowRootAccount"
          Effect    = "Allow"
          Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
          Action    = "kms:*"
          Resource  = "*"
        }
      ],
      [
        # GitHub Actions roles full access
        for role_arn in local.github_roles : {
          Sid       = "AllowGithubActions-${replace(role_arn, "[:/]", "-")}"
          Effect    = "Allow"
          Principal = { AWS = role_arn }
          Action    = "kms:*"
          Resource  = "*"
        }
      ],
      [
        # S3 logging permissions
        {
          Sid       = "AllowS3Logging"
          Effect    = "Allow"
          Principal = { Service = "logging.s3.amazonaws.com" }
          Action = [
            "kms:Encrypt",
            "kms:GenerateDataKey"
          ]
          Resource = "*"
          Condition = {
            StringEquals = {
              "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            }
          }
        }
      ]
    ])
  })
}
