output "ide_security_group_id" {
  description = "Security Group ID for IDE"
  value       = aws_security_group.ide.id
}

output "ide_security_group_arn" {
  description = "Security Group ARN for IDE"
  value       = aws_security_group.ide.arn
}

output "lambda_security_group_id" {
  description = "Security Group ID for Lambda"
  value       = aws_security_group.lambda.id
}
