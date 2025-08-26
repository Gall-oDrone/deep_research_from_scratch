# Random password generator
resource "random_password" "ide_password" {
  length           = 32
  special          = true
  override_special = "!@#$%^&*()_+-=[]{}|;:,.<>?"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

# Secret for IDE password
resource "aws_secretsmanager_secret" "password" {
  name        = "${var.environment}-password"
  description = "Password for IDE access"

  tags = merge(var.common_tags, {
    Name = "${var.environment}-password-secret"
  })
}

# Secret version with the generated password
resource "aws_secretsmanager_secret_version" "password" {
  secret_id = aws_secretsmanager_secret.password.id
  secret_string = jsonencode({
    password = random_password.ide_password.result
  })
}
