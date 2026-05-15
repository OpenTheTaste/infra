variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "base_domain" {
  type = string
}

variable "media_bucket_name" {
  type    = string
  default = null
}

variable "media_force_destroy" {
  type    = bool
  default = false
}

variable "media_enable_lifecycle_rule" {
  type    = bool
  default = false
}

variable "media_enable_cors" {
  type    = bool
  default = false
}

variable "media_cors_allowed_origins" {
  type    = list(string)
  default = []
}

variable "enable_cloudfront" {
  type    = bool
  default = true
}

variable "media_subdomain" {
  type    = string
  default = "media"
}

variable "media_cloudfront_use_custom_domain" {
  type    = bool
  default = false
}

variable "media_cloudfront_acm_certificate_arn" {
  type    = string
  default = null
}

variable "media_cloudfront_enable_signed_cookies" {
  type    = bool
  default = false
}

variable "media_cloudfront_public_key_pem" {
  type    = string
  default = null
}

variable "media_cloudfront_trusted_key_group_ids" {
  type    = list(string)
  default = []
}

variable "media_cloudfront_price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "create_cloudfront_auth_parameters" {
  type    = bool
  default = true
}

variable "cloudfront_signed_cookie_public_key_id" {
  type    = string
  default = null
}

variable "admin_subdomain" {
  type    = string
  default = "admin"
}

variable "route53_create_hosted_zone" {
  type    = bool
  default = true
}

variable "route53_existing_zone_id" {
  type    = string
  default = null
}

variable "enable_lambda_worker" {
  type    = bool
  default = false
}

variable "enable_ecs_transcoder" {
  type    = bool
  default = true
}

variable "ecs_transcoder_container_image" {
  type    = string
  default = "public.ecr.aws/docker/library/nginx:stable"
}

variable "ecs_transcoder_task_cpu" {
  type    = number
  default = 512
}

variable "ecs_transcoder_task_memory" {
  type    = number
  default = 1024
}

variable "ecs_transcoder_desired_count" {
  type    = number
  default = 0
}

variable "ecs_transcoder_log_retention_days" {
  type    = number
  default = 7
}

variable "ecs_transcoder_container_environment" {
  type    = map(string)
  default = {}
}

variable "lambda_package_file" {
  type    = string
  default = null
}

variable "lambda_rabbitmq_credentials_secret_arn" {
  type    = string
  default = null
}

variable "create_lambda_rabbitmq_credentials_secret" {
  type    = bool
  default = true
}

variable "lambda_rabbitmq_username" {
  type    = string
  default = "scaler"
}

variable "lambda_rabbitmq_password_length" {
  type    = number
  default = 24
}

variable "lambda_rabbitmq_secret_name" {
  type    = string
  default = null
}

variable "rabbitmq_admin_credentials_secret_arn" {
  type    = string
  default = null
}

variable "create_rabbitmq_admin_credentials_secret" {
  type    = bool
  default = true
}

variable "rabbitmq_admin_username" {
  type    = string
  default = "admin"
}

variable "rabbitmq_admin_password_length" {
  type    = number
  default = 24
}

variable "rabbitmq_admin_secret_name" {
  type    = string
  default = null
}

variable "enable_rabbitmq_credentials_rotation" {
  type    = bool
  default = true
}

variable "rabbitmq_credentials_rotation_days" {
  type    = number
  default = 30
}

variable "rabbitmq_rotation_lambda_package_file" {
  type    = string
  default = "../../artifacts/lambda/rabbitmq_rotation/dist/rabbitmq_rotation.zip"
}

variable "lambda_rabbitmq_api_base_url" {
  type    = string
  default = null
}

variable "lambda_rabbitmq_vhost" {
  type    = string
  default = "/"
}

variable "lambda_rabbitmq_queue_name" {
  type    = string
  default = "transcode.queue"
}

variable "lambda_rabbitmq_api_timeout_sec" {
  type    = number
  default = 5
}

variable "lambda_ecs_cluster_name" {
  type    = string
  default = null
}

variable "lambda_ecs_service_name" {
  type    = string
  default = null
}

variable "lambda_messages_per_instance" {
  type    = number
  default = 5
}

variable "lambda_min_desired_count" {
  type    = number
  default = 0
}

variable "lambda_max_desired_count" {
  type    = number
  default = null
}

variable "lambda_scale_cooldown_seconds" {
  type    = number
  default = 120
}

variable "lambda_max_scale_step" {
  type    = number
  default = 1
}

variable "lambda_handler" {
  type    = string
  default = "index.lambda_handler"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.12"
}

variable "lambda_memory_size" {
  type    = number
  default = 256
}

variable "lambda_timeout" {
  type    = number
  default = 30
}

variable "lambda_vpc_subnet_ids" {
  type    = list(string)
  default = []
}

variable "enable_eventbridge_schedule" {
  type    = bool
  default = false
}

variable "eventbridge_schedule_expression" {
  type    = string
  default = "rate(1 minute)"
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "monitoring_instance_type" {
  type    = string
  default = "t3.small"
}

variable "monitoring_root_volume_size" {
  type    = number
  default = 40
}

variable "monitoring_key_name" {
  type    = string
  default = null
}

variable "monitoring_grafana_admin_user" {
  type    = string
  default = "admin"
}

variable "monitoring_grafana_admin_password" {
  type      = string
  sensitive = true
  default   = null
}

variable "monitoring_prometheus_scrape_targets" {
  type = list(object({
    target       = string
    metrics_path = string
  }))
  default = []
}

variable "monitoring_grafana_admin_secret_arn" {
  type    = string
  default = null
}

variable "create_monitoring_grafana_admin_secret" {
  type    = bool
  default = true
}

variable "monitoring_grafana_admin_password_length" {
  type    = number
  default = 24
}

variable "monitoring_grafana_admin_secret_name" {
  type    = string
  default = null
}

variable "api_user_env_parameter_value" {
  type    = string
  default = "SPRING_PROFILES_ACTIVE=dev"
}

variable "api_admin_env_parameter_value" {
  type    = string
  default = "SPRING_PROFILES_ACTIVE=dev"
}

variable "machine_env_parameter_value" {
  type    = string
  default = "SPRING_PROFILES_ACTIVE=dev"
}
