output "media_cloudfront_domain_name" {
  value = module.orchestrator.media_cloudfront_domain_name
}

output "media_cloudfront_url" {
  value = module.orchestrator.media_cloudfront_url
}

output "media_cloudfront_key_group_id" {
  value = module.orchestrator.media_cloudfront_key_group_id
}

output "cloudfront_auth_parameter_names" {
  value = module.orchestrator.cloudfront_auth_parameter_names
}

output "monitoring_instance_id" {
  value = module.orchestrator.monitoring_instance_id
}

output "monitoring_private_ip" {
  value = module.orchestrator.monitoring_private_ip
}

output "monitoring_grafana_private_url" {
  value = module.orchestrator.monitoring_grafana_private_url
}

output "monitoring_grafana_admin_secret_arn" {
  value = module.orchestrator.monitoring_grafana_admin_secret_arn
}
