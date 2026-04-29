output "certificate_arn" {
  description = "ACM certificate ARN."
  value       = aws_acm_certificate.this.arn
}

output "certificate_domain_name" {
  description = "Primary domain name of the ACM certificate."
  value       = aws_acm_certificate.this.domain_name
}

output "validation_status" {
  description = "Validation status of the ACM certificate."
  value       = aws_acm_certificate.this.status
}
