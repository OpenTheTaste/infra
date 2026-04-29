output "vpc_id" {
  description = "VPC ID for the app stack."
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "ALB DNS name."
  value       = module.alb.alb_dns_name
}

output "lambda_function_name" {
  description = "Worker Lambda function name."
  value       = try(module.lambda_worker[0].function_name, null)
}

output "lambda_function_arn" {
  description = "Worker Lambda function ARN."
  value       = try(module.lambda_worker[0].function_arn, null)
}

output "rabbitmq_credentials_secret_arn" {
  description = "RabbitMQ target credentials secret ARN."
  value       = local.lambda_secret_arn
}

output "rabbitmq_admin_credentials_secret_arn" {
  description = "RabbitMQ admin credentials secret ARN."
  value       = local.rabbitmq_admin_secret_arn
}

output "media_bucket_name" {
  description = "Media S3 bucket name."
  value       = module.s3_media.bucket_name
}

output "media_bucket_arn" {
  description = "Media S3 bucket ARN."
  value       = module.s3_media.bucket_arn
}

output "media_cloudfront_domain_name" {
  description = "CloudFront domain name for media delivery."
  value       = try(module.cloudfront[0].distribution_domain_name, null)
}

output "media_cloudfront_url" {
  description = "CloudFront URL for media delivery."
  value       = try(module.cloudfront[0].url, null)
}

output "media_cloudfront_key_group_id" {
  description = "CloudFront key group ID used for signed cookies (if created)."
  value       = try(module.cloudfront[0].created_key_group_id, null)
}

output "cloudfront_auth_parameter_names" {
  description = "SSM parameter names for CloudFront signed-cookie integration."
  value       = try(module.cloudfront_auth_parameters[0].parameter_names, {})
}

output "ecs_transcoder_cluster_name" {
  description = "ECS transcoder cluster name."
  value       = try(module.ecs_transcoder[0].cluster_name, null)
}

output "ecs_transcoder_service_name" {
  description = "ECS transcoder service name."
  value       = try(module.ecs_transcoder[0].service_name, null)
}

output "ecs_transcoder_task_family" {
  description = "ECS transcoder task definition family."
  value       = try(module.ecs_transcoder[0].task_definition_family, null)
}

output "monitoring_instance_id" {
  description = "Monitoring EC2 instance ID."
  value       = try(module.monitoring[0].instance_id, null)
}

output "monitoring_private_ip" {
  description = "Monitoring EC2 private IP."
  value       = try(module.monitoring[0].private_ip, null)
}

output "monitoring_grafana_private_url" {
  description = "Monitoring Grafana private URL."
  value       = try(module.monitoring[0].grafana_private_url, null)
}

output "monitoring_grafana_admin_secret_arn" {
  description = "Secrets Manager ARN for monitoring Grafana admin credentials."
  value       = local.monitoring_grafana_secret_arn
}
