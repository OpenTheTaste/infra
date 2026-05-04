terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0"
      configuration_aliases = [aws.us_east_1]
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  admin_host                       = "${var.admin_subdomain}.${var.base_domain}"
  media_host                       = "${var.media_subdomain}.${var.base_domain}"
  media_bucket_name                = coalesce(var.media_bucket_name, "${var.project}-${var.environment}-media-${data.aws_caller_identity.current.account_id}")
  lambda_subnet_ids                = length(var.lambda_vpc_subnet_ids) > 0 ? var.lambda_vpc_subnet_ids : module.vpc.private_subnet_ids
  transcoder_cluster_name          = coalesce(var.lambda_ecs_cluster_name, try(module.ecs_transcoder[0].cluster_name, null))
  transcoder_service_name          = coalesce(var.lambda_ecs_service_name, try(module.ecs_transcoder[0].service_name, null))
  lambda_parameter_prefix          = "/${var.project}/${var.environment}/lambda/worker"
  cloudfront_auth_parameter_prefix = "/${var.project}/${var.environment}/cloudfront/auth"
  lambda_ecs_service_arn           = var.enable_lambda_worker && local.transcoder_cluster_name != null && local.transcoder_service_name != null ? "arn:aws:ecs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:service/${local.transcoder_cluster_name}/${local.transcoder_service_name}" : null
  rabbitmq_api_base_url            = coalesce(var.lambda_rabbitmq_api_base_url, "http://${module.rabbitmq.private_ip}:15672")
  rabbitmq_bootstrap_secret_arns = compact([
    local.lambda_secret_arn,
    local.rabbitmq_admin_secret_arn
  ])
  monitoring_secret_arns = compact([
    local.monitoring_grafana_secret_arn
  ])
  lambda_runtime_parameters = merge(
    {
      rabbitmq_api_base_url    = local.rabbitmq_api_base_url
      rabbitmq_vhost           = var.lambda_rabbitmq_vhost
      rabbitmq_queue_name      = var.lambda_rabbitmq_queue_name
      rabbitmq_api_timeout_sec = tostring(var.lambda_rabbitmq_api_timeout_sec)
      ecs_cluster_name         = local.transcoder_cluster_name
      ecs_service_name         = local.transcoder_service_name
      messages_per_instance    = tostring(var.lambda_messages_per_instance)
      min_desired_count        = tostring(var.lambda_min_desired_count)
      scale_cooldown_seconds   = tostring(var.lambda_scale_cooldown_seconds)
      max_scale_step           = tostring(var.lambda_max_scale_step)
      last_scale_epoch         = "0"
    },
    var.lambda_max_desired_count == null ? {} : { max_desired_count = tostring(var.lambda_max_desired_count) }
  )

  common_tags = {
    Project = var.project
    Env     = var.environment
  }

  lambda_secret_arn             = var.lambda_rabbitmq_credentials_secret_arn != null ? var.lambda_rabbitmq_credentials_secret_arn : try(aws_secretsmanager_secret.lambda_rabbitmq_credentials[0].arn, null)
  rabbitmq_admin_secret_arn     = var.rabbitmq_admin_credentials_secret_arn != null ? var.rabbitmq_admin_credentials_secret_arn : try(aws_secretsmanager_secret.rabbitmq_admin_credentials[0].arn, null)
  monitoring_grafana_secret_arn = var.monitoring_grafana_admin_secret_arn != null ? var.monitoring_grafana_admin_secret_arn : try(aws_secretsmanager_secret.monitoring_grafana_admin_credentials[0].arn, null)

  monitoring_auto_scrape_targets = [
    { target = "${module.admin_ec2.private_ip}:8081", metrics_path = "/actuator/prometheus" },
    { target = "${module.user_ec2.private_ip}:8080", metrics_path = "/actuator/prometheus" }
  ]

  monitoring_effective_scrape_targets = values({
    for t in concat(var.monitoring_prometheus_scrape_targets, local.monitoring_auto_scrape_targets) :
    "${t.target}|${t.metrics_path}" => t
  })

  # Keep count conditions plan-time deterministic (avoid depending on resources created in same apply).
  rabbitmq_rotation_enabled = (
    var.enable_rabbitmq_credentials_rotation &&
    var.enable_lambda_worker &&
    (var.lambda_rabbitmq_credentials_secret_arn != null || (var.create_lambda_rabbitmq_credentials_secret && var.enable_lambda_worker)) &&
    (var.rabbitmq_admin_credentials_secret_arn != null || var.create_rabbitmq_admin_credentials_secret)
  )
}


