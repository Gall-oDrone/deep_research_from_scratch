output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.ide.id
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.ide.domain_name
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.ide.arn
}

output "cache_policy_id" {
  description = "CloudFront cache policy ID"
  value       = aws_cloudfront_cache_policy.ide.id
}
