output "ide_url" {
  description = "URL to access the code-server IDE"
  value       = module.cloudfront.distribution_domain_name
}

output "ide_password_secret_name" {
  description = "Name of the secret containing the IDE password"
  value       = module.secrets.password_secret_name
}

output "ide_password_secret_arn" {
  description = "ARN of the secret containing the IDE password"
  value       = module.secrets.password_secret_arn
}

output "ide_role_arn" {
  description = "IAM Role ARN used by the IDE instance"
  value       = module.iam.instance_role_arn
}

output "instance_id" {
  description = "EC2 Instance ID of the IDE"
  value       = module.ec2.instance_id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.public_ip
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID"
  value       = module.cloudfront.distribution_id
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "security_group_id" {
  description = "Security Group ID for the IDE"
  value       = module.security_groups.ide_security_group_id
}
