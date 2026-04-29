output "zone_id" {
  description = "Hosted zone ID used by this module."
  value       = local.zone_id
}

output "name_servers" {
  description = "Hosted zone name servers when zone is created."
  value       = try(aws_route53_zone.this[0].name_servers, [])
}

output "apex_record_fqdn" {
  description = "Apex record FQDN."
  value       = try(aws_route53_record.apex[0].fqdn, null)
}

output "admin_record_fqdn" {
  description = "Admin record FQDN when created."
  value       = try(aws_route53_record.admin[0].fqdn, null)
}
