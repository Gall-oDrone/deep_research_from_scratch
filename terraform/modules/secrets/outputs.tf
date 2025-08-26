output "password_secret_id" {
  description = "ID of the password secret"
  value       = aws_secretsmanager_secret.password.id
}

output "password_secret_arn" {
  description = "ARN of the password secret"
  value       = aws_secretsmanager_secret.password.arn
}

output "password_secret_name" {
  description = "Name of the password secret"
  value       = aws_secretsmanager_secret.password.name
}

output "password_secret_version_id" {
  description = "Version ID of the password secret"
  value       = aws_secretsmanager_secret_version.password.version_id
}
