# Security Group for IDE
resource "aws_security_group" "ide" {
  name_prefix = "${var.environment}-ide-sg-"
  vpc_id      = var.vpc_id

  description = "Security group for IDE instance"

  # Allow HTTP from CloudFront
  ingress {
    description = "HTTP from CloudFront"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from CloudFront
  ingress {
    description = "HTTPS from CloudFront"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Code-Server port (8889)
  ingress {
    description = "Code-Server IDE"
    from_port   = 8889
    to_port     = 8889
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Jupyter Notebook port (8888)
  ingress {
    description = "Jupyter Notebook"
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow additional Jupyter ports for different kernels
  ingress {
    description = "Jupyter Kernel Gateway"
    from_port   = 8887
    to_port     = 8887
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow WebSocket connections for real-time features
  ingress {
    description = "WebSocket connections"
    from_port   = 8889
    to_port     = 8889
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH access for debugging
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-ide-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for Lambda (if needed)
resource "aws_security_group" "lambda" {
  name_prefix = "${var.environment}-lambda-sg-"
  vpc_id      = var.vpc_id

  description = "Security group for Lambda functions"

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-lambda-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}
