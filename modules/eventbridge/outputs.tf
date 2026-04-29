output "event_bus_name" {
  description = "Event bus name used by this module."
  value       = "default"
}

output "rule_name" {
  description = "Created EventBridge rule name."
  value       = try(aws_cloudwatch_event_rule.this[0].name, null)
}

output "rule_arn" {
  description = "Created EventBridge rule ARN."
  value       = try(aws_cloudwatch_event_rule.this[0].arn, null)
}
