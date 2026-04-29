output "parameter_names" {
  description = "Created SSM parameter names by key."
  value       = { for k, v in aws_ssm_parameter.this : k => v.name }
}

output "parameter_arns" {
  description = "Created SSM parameter ARNs by key."
  value       = { for k, v in aws_ssm_parameter.this : k => v.arn }
}
