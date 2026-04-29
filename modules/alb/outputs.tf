output "alb_arn" {
  description = "ALB ARN."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "ALB DNS name."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the ALB."
  value       = aws_lb.this.zone_id
}

output "alb_security_group_id" {
  description = "Security group ID attached to ALB."
  value       = local.effective_alb_security_group_ids[0]
}

output "http_listener_arn" {
  description = "HTTP listener ARN."
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN, if enabled."
  value       = try(aws_lb_listener.https[0].arn, null)
}

output "target_group_arns" {
  description = "Map of target group ARNs by key."
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
}
