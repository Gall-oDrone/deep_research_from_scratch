variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "eks-workshop"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for the IDE"
  type        = string
  default     = "t3.medium"
}

variable "instance_volume_size" {
  description = "Size in GB of the EC2 instance volume"
  type        = number
  default     = 30
}

variable "code_server_version" {
  description = "Code-server version to install"
  type        = string
  default     = "4.91.1"
}

variable "repository_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "aws-samples"
}

variable "repository_name" {
  description = "GitHub repository name"
  type        = string
  default     = "eks-workshop-v2"
}

variable "repository_ref" {
  description = "Git reference (branch/tag) to use"
  type        = string
  default     = "main"
}

variable "resources_precreated" {
  description = "Whether lab infrastructure has been pre-provisioned"
  type        = string
  default     = "false"
}

variable "analytics_endpoint" {
  description = "Analytics endpoint for AWS events"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "eks-workshop"
    Project     = "deep-research"
    ManagedBy   = "terraform"
  }
}
