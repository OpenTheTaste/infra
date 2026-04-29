output "instance_id" {
  description = "Monitoring EC2 instance ID."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Monitoring EC2 private IP."
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "Monitoring security group ID."
  value       = var.security_group_id
}

output "grafana_private_url" {
  description = "Grafana private URL."
  value       = "http://${aws_instance.this.private_ip}:3000"
}
