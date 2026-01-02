output "lambda_at_edge_arn" {
  value = aws_lambda_function.spa_fallback.qualified_arn
}