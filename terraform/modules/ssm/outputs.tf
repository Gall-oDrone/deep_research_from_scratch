output "ssm_document_name" {
  description = "Name of the SSM document"
  value       = aws_ssm_document.bootstrap.name
}

output "ssm_document_arn" {
  description = "ARN of the SSM document"
  value       = aws_ssm_document.bootstrap.arn
}
