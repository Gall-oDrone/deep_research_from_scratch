terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC and Networking
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = data.aws_availability_zones.available.names
  environment          = var.environment
  common_tags          = var.common_tags
}

# Security Groups
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id     = module.vpc.vpc_id
  environment = var.environment
  common_tags = var.common_tags
}

# IAM Roles and Policies
module "iam" {
  source = "./modules/iam"

  environment = var.environment
  common_tags = var.common_tags
}

# Secrets Manager
module "secrets" {
  source = "./modules/secrets"

  environment = var.environment
  common_tags = var.common_tags
}

# EC2 Instance
module "ec2" {
  source = "./modules/ec2"

  ami_id                    = data.aws_ami.amazon_linux_2023.id
  instance_type             = var.instance_type
  subnet_id                 = module.vpc.public_subnet_ids[0]
  security_group_ids        = [module.security_groups.ide_security_group_id]
  iam_instance_profile_name = module.iam.instance_profile_name
  volume_size               = var.instance_volume_size
  environment               = var.environment
  common_tags               = var.common_tags

  depends_on = [
    module.iam,
    module.secrets
  ]
}

# CloudFront Distribution
module "cloudfront" {
  source = "./modules/cloudfront"

  domain_name    = module.ec2.public_dns_name
  environment    = var.environment
  common_tags    = var.common_tags

  depends_on = [
    module.ec2
  ]
}

# Lambda for Bootstrap
module "lambda" {
  source = "./modules/lambda"

  environment = var.environment
  common_tags = var.common_tags

  depends_on = [
    module.ec2,
    module.secrets,
    module.cloudfront
  ]
}

# SSM Document
module "ssm" {
  source = "./modules/ssm"

  environment = var.environment
  common_tags = var.common_tags

  depends_on = [
    module.ec2,
    module.secrets,
    module.cloudfront
  ]
}
