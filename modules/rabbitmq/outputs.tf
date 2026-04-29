output "instance_id" {
  description = "RabbitMQ EC2 instance ID."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "RabbitMQ EC2 private IP."
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "RabbitMQ security group ID."
  value       = var.security_group_id
}
