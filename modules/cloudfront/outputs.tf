output "distribution_id" {
  description = "CloudFront distribution ID."
  value       = try(aws_cloudfront_distribution.this[0].id, null)
}

output "distribution_arn" {
  description = "CloudFront distribution ARN."
  value       = try(aws_cloudfront_distribution.this[0].arn, null)
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name."
  value       = try(aws_cloudfront_distribution.this[0].domain_name, null)
}

output "distribution_hosted_zone_id" {
  description = "CloudFront hosted zone ID for Route53 alias records."
  value       = try(aws_cloudfront_distribution.this[0].hosted_zone_id, null)
}

output "url" {
  description = "HTTPS URL for CloudFront distribution."
  value       = try("https://${aws_cloudfront_distribution.this[0].domain_name}", null)
}

output "created_key_group_id" {
  description = "Created CloudFront key group ID for signed cookies (if created)."
  value       = try(aws_cloudfront_key_group.this[0].id, null)
}

output "created_public_key_id" {
  description = "Created CloudFront public key ID (if created)."
  value       = try(aws_cloudfront_public_key.this[0].id, null)
}
