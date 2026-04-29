output "media_cloudfront_domain_name" {
  value = module.app_stack.media_cloudfront_domain_name
}

output "media_cloudfront_url" {
  value = module.app_stack.media_cloudfront_url
}

output "media_cloudfront_key_group_id" {
  value = module.app_stack.media_cloudfront_key_group_id
}

output "cloudfront_auth_parameter_names" {
  value = module.app_stack.cloudfront_auth_parameter_names
}

output "monitoring_instance_id" {
  value = module.app_stack.monitoring_instance_id
}

output "monitoring_private_ip" {
  value = module.app_stack.monitoring_private_ip
}

output "monitoring_grafana_private_url" {
  value = module.app_stack.monitoring_grafana_private_url
}

output "monitoring_grafana_admin_secret_arn" {
  value = module.app_stack.monitoring_grafana_admin_secret_arn
}
