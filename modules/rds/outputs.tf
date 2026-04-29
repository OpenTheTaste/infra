output "db_instance_id" {
  description = "RDS instance resource ID."
  value       = aws_db_instance.this.id
}

output "db_instance_identifier" {
  description = "RDS instance identifier."
  value       = aws_db_instance.this.identifier
}

output "endpoint" {
  description = "RDS endpoint (host:port)."
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "RDS endpoint address."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS port."
  value       = aws_db_instance.this.port
}

output "security_group_id" {
  description = "RDS security group ID."
  value       = local.primary_security_group_id
}

output "subnet_group_name" {
  description = "DB subnet group name."
  value       = aws_db_subnet_group.this.name
}
