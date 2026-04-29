output "security_group_id" {
  description = "Security group ID for the EC2 service."
  value       = local.primary_security_group_id
}

output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP address of the EC2 instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address of the EC2 instance, if assigned."
  value       = aws_instance.this.public_ip
}
