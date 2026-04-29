output "alb_sg_id" {
  description = "ALB security group ID."
  value       = aws_security_group.alb.id
}

output "admin_sg_id" {
  description = "Admin service security group ID."
  value       = aws_security_group.admin.id
}

output "user_sg_id" {
  description = "User service security group ID."
  value       = aws_security_group.user.id
}

output "rds_sg_id" {
  description = "RDS security group ID."
  value       = aws_security_group.rds.id
}

output "rabbitmq_sg_id" {
  description = "RabbitMQ security group ID."
  value       = aws_security_group.rabbitmq.id
}

output "lambda_sg_id" {
  description = "Lambda worker security group ID."
  value       = aws_security_group.lambda.id
}

output "monitoring_sg_id" {
  description = "Monitoring server security group ID."
  value       = aws_security_group.monitoring.id
}
