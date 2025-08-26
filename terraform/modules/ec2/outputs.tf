output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.ide.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ide.public_ip
}

output "public_dns_name" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.ide.public_dns_name
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.ide.private_ip
}
