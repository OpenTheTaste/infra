variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, stage, prod)."
  type        = string
}

variable "base_domain" {
  description = "Base domain for public endpoints."
  type        = string
}

variable "media_bucket_name" {
  description = "Optional media S3 bucket name. If null, stack generates one."
  type        = string
  default     = null
}

variable "media_force_destroy" {
  description = "Delete all S3 objects when destroying media bucket."
  type        = bool
  default     = false
}

variable "media_enable_lifecycle_rule" {
  description = "Enable default lifecycle rule for media bucket."
  type        = bool
  default     = false
}

variable "media_enable_cors" {
  description = "Enable CORS on media bucket."
  type        = bool
  default     = true
}

variable "media_cors_allowed_origins" {
  description = "Allowed origins for media bucket CORS."
  type        = list(string)
  default     = []
}

variable "enable_cloudfront" {
  description = "Whether to create CloudFront distribution for media bucket."
  type        = bool
  default     = true
}

variable "media_subdomain" {
  description = "Subdomain label for media CDN when custom domain is enabled."
  type        = string
  default     = "media"
}

variable "media_cloudfront_use_custom_domain" {
  description = "Use media subdomain alias (media_subdomain.base_domain) on CloudFront."
  type        = bool
  default     = false
}

variable "media_cloudfront_acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for media CloudFront custom domain."
  type        = string
  default     = null
}

variable "media_cloudfront_enable_signed_cookies" {
  description = "Enable signed cookie authorization on CloudFront."
  type        = bool
  default     = false
}

variable "media_cloudfront_public_key_pem" {
  description = "Optional PEM public key to create CloudFront key group for signed cookies."
  type        = string
  default     = null
}

variable "media_cloudfront_trusted_key_group_ids" {
  description = "Existing CloudFront key group IDs trusted for signed cookies."
  type        = list(string)
  default     = []
}

variable "media_cloudfront_price_class" {
  description = "CloudFront price class for pay-as-you-go mode."
  type        = string
  default     = "PriceClass_100"
}

variable "create_cloudfront_auth_parameters" {
  description = "Create SSM parameters for CloudFront signed-cookie integration (domain/key-group/public-key-id)."
  type        = bool
  default     = true
}

variable "cloudfront_signed_cookie_public_key_id" {
  description = "CloudFront public key ID used by backend when issuing Signed Cookies (CloudFront-Key-Pair-Id)."
  type        = string
  default     = null
}

variable "admin_subdomain" {
  description = "Admin subdomain label."
  type        = string
  default     = "admin"
}

variable "monitoring_subdomain" {
  description = "Monitoring subdomain label."
  type        = string
  default     = "monitoring"
}

variable "route53_create_hosted_zone" {
  description = "Create hosted zone for base_domain when true."
  type        = bool
  default     = true
}

variable "route53_existing_zone_id" {
  description = "Existing hosted zone ID to use when route53_create_hosted_zone is false."
  type        = string
  default     = null
}

variable "enable_lambda_worker" {
  description = "Whether to create the worker Lambda function."
  type        = bool
  default     = false
}

variable "enable_ecs_transcoder" {
  description = "Whether to create ECS transcoder service."
  type        = bool
  default     = true
}

variable "ecs_transcoder_container_image" {
  description = "Container image for ECS transcoder."
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:stable"
}

variable "ecs_transcoder_task_cpu" {
  description = "ECS transcoder task CPU units."
  type        = number
  default     = 512
}

variable "ecs_transcoder_task_memory" {
  description = "ECS transcoder task memory (MiB)."
  type        = number
  default     = 1024
}

variable "ecs_transcoder_desired_count" {
  description = "Initial ECS transcoder desired count."
  type        = number
  default     = 0
}

variable "ecs_transcoder_log_retention_days" {
  description = "CloudWatch log retention for ECS transcoder."
  type        = number
  default     = 7
}

variable "ecs_transcoder_container_environment" {
  description = "Additional environment variables for transcoder container."
  type        = map(string)
  default     = {}
}

variable "lambda_package_file" {
  description = "Path to the worker Lambda zip package. Required when enable_lambda_worker is true."
  type        = string
  default     = null
}

variable "lambda_rabbitmq_credentials_secret_arn" {
  description = "Secrets Manager ARN containing RabbitMQ credentials JSON (username/password)."
  type        = string
  default     = null
}

variable "create_lambda_rabbitmq_credentials_secret" {
  description = "Create RabbitMQ credentials secret automatically when true and ARN is not provided."
  type        = bool
  default     = true
}

variable "lambda_rabbitmq_username" {
  description = "Username stored in autogenerated RabbitMQ credentials secret."
  type        = string
  default     = "scaler"
}

variable "lambda_rabbitmq_password_length" {
  description = "Random password length for autogenerated RabbitMQ credentials secret."
  type        = number
  default     = 24

  validation {
    condition     = var.lambda_rabbitmq_password_length >= 16
    error_message = "lambda_rabbitmq_password_length must be >= 16."
  }
}

variable "lambda_rabbitmq_secret_name" {
  description = "Optional explicit secret name for autogenerated RabbitMQ credentials secret."
  type        = string
  default     = null
}

variable "enable_rabbitmq_credentials_rotation" {
  description = "Enable Secrets Manager native rotation for RabbitMQ credentials."
  type        = bool
  default     = true
}

variable "rabbitmq_credentials_rotation_days" {
  description = "Rotation interval in days for RabbitMQ credentials secret."
  type        = number
  default     = 30
}

variable "rabbitmq_rotation_lambda_package_file" {
  description = "Path to the zipped RabbitMQ rotation Lambda package."
  type        = string
  default     = "../../artifacts/lambda/rabbitmq_rotation/dist/rabbitmq_rotation.zip"
}

variable "rabbitmq_admin_credentials_secret_arn" {
  description = "Secrets Manager ARN containing RabbitMQ admin credentials JSON (username/password) for rotation lambda."
  type        = string
  default     = null
}

variable "create_rabbitmq_admin_credentials_secret" {
  description = "Create RabbitMQ admin credentials secret automatically when true and ARN is not provided."
  type        = bool
  default     = true
}

variable "rabbitmq_admin_username" {
  description = "Username stored in autogenerated RabbitMQ admin credentials secret."
  type        = string
  default     = "admin"
}

variable "rabbitmq_admin_password_length" {
  description = "Random password length for autogenerated RabbitMQ admin credentials secret."
  type        = number
  default     = 24

  validation {
    condition     = var.rabbitmq_admin_password_length >= 16
    error_message = "rabbitmq_admin_password_length must be >= 16."
  }
}

variable "rabbitmq_admin_secret_name" {
  description = "Optional explicit secret name for autogenerated RabbitMQ admin credentials secret."
  type        = string
  default     = null
}

variable "lambda_rabbitmq_api_base_url" {
  description = "RabbitMQ management API base URL (non-sensitive). If null, stack uses rabbitmq private IP with port 15672."
  type        = string
  default     = null
}

variable "lambda_rabbitmq_vhost" {
  description = "RabbitMQ vhost for queue inspection."
  type        = string
  default     = "/"
}

variable "lambda_rabbitmq_queue_name" {
  description = "RabbitMQ queue name to monitor."
  type        = string
  default     = "transcode.queue"
}

variable "lambda_rabbitmq_api_timeout_sec" {
  description = "RabbitMQ management API timeout in seconds."
  type        = number
  default     = 5
}

variable "lambda_ecs_cluster_name" {
  description = "Optional ECS cluster name override for scaler target."
  type        = string
  default     = null
}

variable "lambda_ecs_service_name" {
  description = "Optional ECS service name override for scaler target."
  type        = string
  default     = null
}

variable "lambda_messages_per_instance" {
  description = "Queue messages handled per ECS task unit."
  type        = number
  default     = 5
}

variable "lambda_min_desired_count" {
  description = "Minimum ECS desired count."
  type        = number
  default     = 0
}

variable "lambda_max_desired_count" {
  description = "Optional maximum ECS desired count."
  type        = number
  default     = null
}

variable "lambda_scale_cooldown_seconds" {
  description = "Minimum seconds between scaling actions."
  type        = number
  default     = 120
}

variable "lambda_max_scale_step" {
  description = "Maximum desired count change per invocation."
  type        = number
  default     = 1

  validation {
    condition     = var.lambda_max_scale_step >= 1
    error_message = "lambda_max_scale_step must be >= 1."
  }
}

variable "lambda_handler" {
  description = "Lambda handler string."
  type        = string
  default     = "index.lambda_handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "python3.12"
}

variable "lambda_memory_size" {
  description = "Lambda memory size (MB)."
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Lambda timeout (seconds)."
  type        = number
  default     = 30
}

variable "lambda_vpc_subnet_ids" {
  description = "Optional subnet IDs for Lambda VPC config. If empty, app private subnets are used."
  type        = list(string)
  default     = []
}

variable "enable_eventbridge_schedule" {
  description = "Whether to enable 1-minute EventBridge schedule for Lambda."
  type        = bool
  default     = false
}

variable "eventbridge_schedule_expression" {
  description = "EventBridge schedule expression."
  type        = string
  default     = "rate(1 minute)"
}

variable "enable_monitoring" {
  description = "Whether to create monitoring EC2 server (Grafana/Prometheus/Loki)."
  type        = bool
  default     = false
}

variable "monitoring_instance_type" {
  description = "EC2 instance type for monitoring server."
  type        = string
  default     = "t3.small"
}

variable "monitoring_root_volume_size" {
  description = "Root volume size (GiB) for monitoring server."
  type        = number
  default     = 40
}

variable "monitoring_key_name" {
  description = "Optional EC2 key pair name for monitoring server."
  type        = string
  default     = null
}

variable "monitoring_grafana_admin_user" {
  description = "Grafana admin username."
  type        = string
  default     = "admin"
}

variable "monitoring_grafana_admin_password" {
  description = "Grafana admin password."
  type        = string
  sensitive   = true
  default     = null
}

variable "monitoring_prometheus_scrape_targets" {
  description = "Additional Prometheus scrape targets."
  type = list(object({
    target       = string
    metrics_path = string
  }))
  default = []
}

variable "monitoring_grafana_admin_secret_arn" {
  description = "Secrets Manager ARN containing Grafana admin credentials JSON (username/password)."
  type        = string
  default     = null
}

variable "create_monitoring_grafana_admin_secret" {
  description = "Create Grafana admin credentials secret automatically when true and ARN is not provided."
  type        = bool
  default     = true
}

variable "monitoring_grafana_admin_password_length" {
  description = "Random password length for autogenerated Grafana admin credentials secret."
  type        = number
  default     = 24
}

variable "monitoring_grafana_admin_secret_name" {
  description = "Optional explicit secret name for autogenerated Grafana admin credentials secret."
  type        = string
  default     = null
}

variable "api_user_env_parameter_value" {
  description = "SSM parameter value for /<project>/<env>/api-user/env."
  type        = string
  default     = "SPRING_PROFILES_ACTIVE=dev"
}

variable "api_admin_env_parameter_value" {
  description = "SSM parameter value for /<project>/<env>/api-admin/env."
  type        = string
  default     = "SPRING_PROFILES_ACTIVE=dev"
}

variable "machine_env_parameter_value" {
  description = "SSM parameter value for /<project>/<env>/machine/env."
  type        = string
  default     = "SPRING_PROFILES_ACTIVE=dev"
}
