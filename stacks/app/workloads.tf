module "admin_ec2" {
  source = "../../modules/ec2_service"

  name                      = "admin"
  vpc_id                    = module.vpc.vpc_id
  subnet_id                 = module.vpc.private_subnet_ids[0]
  ami_id                    = module.ami_linux.id
  iam_instance_profile_name = module.app_ec2_iam.instance_profile_name
  security_group_id         = module.security_groups.admin_sg_id

  instance_type = "t3.medium"
  user_data     = <<-EOT
    #!/bin/bash
    set -euxo pipefail
    dnf -y install docker
    systemctl enable docker
    systemctl restart docker || systemctl start docker
    if ! rpm -q amazon-ssm-agent >/dev/null 2>&1; then
      dnf -y install amazon-ssm-agent || true
    fi
    systemctl enable amazon-ssm-agent || true
    systemctl restart amazon-ssm-agent || systemctl start amazon-ssm-agent || true
  EOT

  target_group_attachments = [
    {
      target_group_arn = module.alb.target_group_arns["admin"]
      port             = 8081
    }
  ]

  tags = local.common_tags
}

module "user_ec2" {
  source = "../../modules/ec2_service"

  name                      = "user"
  vpc_id                    = module.vpc.vpc_id
  subnet_id                 = module.vpc.private_subnet_ids[0]
  ami_id                    = module.ami_linux.id
  iam_instance_profile_name = module.app_ec2_iam.instance_profile_name
  security_group_id         = module.security_groups.user_sg_id

  instance_type = "t3.medium"
  user_data     = <<-EOT
    #!/bin/bash
    set -euxo pipefail
    dnf -y install docker
    systemctl enable docker
    systemctl restart docker || systemctl start docker
    if ! rpm -q amazon-ssm-agent >/dev/null 2>&1; then
      dnf -y install amazon-ssm-agent || true
    fi
    systemctl enable amazon-ssm-agent || true
    systemctl restart amazon-ssm-agent || systemctl start amazon-ssm-agent || true
  EOT

  target_group_attachments = [
    {
      target_group_arn = module.alb.target_group_arns["user"]
      port             = 8080
    }
  ]

  tags = local.common_tags
}

module "rabbitmq" {
  source = "../../modules/rabbitmq"

  name                                  = "rabbitmq"
  subnet_id                             = module.vpc.private_subnet_ids[0]
  security_group_id                     = module.security_groups.rabbitmq_sg_id
  ami_id                                = module.ami_linux.id
  iam_instance_profile_name             = module.rabbitmq_ec2_iam.instance_profile_name
  bootstrap_from_secrets                = local.lambda_secret_arn != null && local.rabbitmq_admin_secret_arn != null
  rabbitmq_admin_credentials_secret_arn = local.rabbitmq_admin_secret_arn
  rabbitmq_app_credentials_secret_arn   = local.lambda_secret_arn

  instance_type = "t3.small"
  tags          = local.common_tags

  depends_on = [
    aws_secretsmanager_secret_version.lambda_rabbitmq_credentials,
    aws_secretsmanager_secret_version.rabbitmq_admin_credentials
  ]
}

module "monitoring" {
  count  = var.enable_monitoring ? 1 : 0
  source = "../../modules/monitoring"

  name                      = "monitoring"
  subnet_id                 = module.vpc.private_subnet_ids[0]
  security_group_id         = module.security_groups.monitoring_sg_id
  ami_id                    = module.ami_linux.id
  iam_instance_profile_name = module.monitoring_ec2_iam[0].instance_profile_name
  instance_type             = var.monitoring_instance_type
  root_volume_size          = var.monitoring_root_volume_size
  key_name                  = var.monitoring_key_name
  grafana_admin_user        = var.monitoring_grafana_admin_user
  grafana_admin_password    = var.monitoring_grafana_admin_password
  grafana_admin_secret_arn  = local.monitoring_grafana_secret_arn
  prometheus_scrape_targets = local.monitoring_effective_scrape_targets

  tags = local.common_tags

  depends_on = [
    aws_secretsmanager_secret_version.monitoring_grafana_admin_credentials
  ]
}

resource "aws_lb_target_group_attachment" "monitoring" {
  count = var.enable_monitoring ? 1 : 0

  target_group_arn = module.alb.target_group_arns["monitoring"]
  target_id        = module.monitoring[0].instance_id
  port             = 3000
}

module "lambda_worker" {
  count  = var.enable_lambda_worker ? 1 : 0
  source = "../../modules/lambda_worker"

  name_prefix        = "${var.project}-${var.environment}"
  role_arn           = module.lambda_iam[0].role_arn
  package_file       = var.lambda_package_file
  handler            = var.lambda_handler
  runtime            = var.lambda_runtime
  memory_size        = var.lambda_memory_size
  timeout            = var.lambda_timeout
  subnet_ids         = local.lambda_subnet_ids
  security_group_ids = [module.security_groups.lambda_sg_id]

  environment_variables = {
    RABBITMQ_API_BASE_URL_PARAM     = module.lambda_parameters[0].parameter_names["rabbitmq_api_base_url"]
    RABBITMQ_VHOST_PARAM            = module.lambda_parameters[0].parameter_names["rabbitmq_vhost"]
    RABBITMQ_QUEUE_NAME_PARAM       = module.lambda_parameters[0].parameter_names["rabbitmq_queue_name"]
    RABBITMQ_API_TIMEOUT_SEC_PARAM  = module.lambda_parameters[0].parameter_names["rabbitmq_api_timeout_sec"]
    ECS_CLUSTER_NAME_PARAM          = module.lambda_parameters[0].parameter_names["ecs_cluster_name"]
    ECS_SERVICE_NAME_PARAM          = module.lambda_parameters[0].parameter_names["ecs_service_name"]
    MESSAGES_PER_INSTANCE_PARAM     = module.lambda_parameters[0].parameter_names["messages_per_instance"]
    MIN_DESIRED_COUNT_PARAM         = module.lambda_parameters[0].parameter_names["min_desired_count"]
    MAX_DESIRED_COUNT_PARAM         = try(module.lambda_parameters[0].parameter_names["max_desired_count"], "")
    SCALE_COOLDOWN_SECONDS_PARAM    = module.lambda_parameters[0].parameter_names["scale_cooldown_seconds"]
    MAX_SCALE_STEP_PARAM            = module.lambda_parameters[0].parameter_names["max_scale_step"]
    LAST_SCALE_EPOCH_PARAM          = module.lambda_parameters[0].parameter_names["last_scale_epoch"]
    RABBITMQ_CREDENTIALS_SECRET_ARN = local.lambda_secret_arn
    PROJECT                         = var.project
    ENV                             = var.environment
  }

  tags = local.common_tags
}

module "eventbridge" {
  source = "../../modules/eventbridge"

  name_prefix = "${var.project}-${var.environment}"
  enabled     = var.enable_eventbridge_schedule && var.enable_lambda_worker

  schedule_expression  = var.eventbridge_schedule_expression
  lambda_target_arn    = var.enable_lambda_worker ? module.lambda_worker[0].function_arn : null
  lambda_function_name = var.enable_lambda_worker ? module.lambda_worker[0].function_name : null

  tags = local.common_tags
}

module "rabbitmq_rotation_lambda" {
  count  = local.rabbitmq_rotation_enabled ? 1 : 0
  source = "../../modules/lambda_worker"

  name_prefix          = "${var.project}-${var.environment}"
  function_name_suffix = "rabbitmq-rotation"
  description          = "Secrets Manager rotation lambda for RabbitMQ credentials"
  role_arn             = module.rabbitmq_rotation_lambda_iam[0].role_arn
  package_file         = var.rabbitmq_rotation_lambda_package_file
  handler              = "index.lambda_handler"
  runtime              = "python3.12"
  memory_size          = 256
  timeout              = 60
  subnet_ids           = local.lambda_subnet_ids
  security_group_ids   = [module.security_groups.lambda_sg_id]

  environment_variables = {
    RABBITMQ_API_BASE_URL                 = local.rabbitmq_api_base_url
    RABBITMQ_ADMIN_CREDENTIALS_SECRET_ARN = local.rabbitmq_admin_secret_arn
  }

  tags = local.common_tags
}

resource "aws_lambda_permission" "allow_secretsmanager_rotation" {
  count = local.rabbitmq_rotation_enabled ? 1 : 0

  statement_id  = "AllowExecutionFromSecretsManagerRotation"
  action        = "lambda:InvokeFunction"
  function_name = module.rabbitmq_rotation_lambda[0].function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = local.lambda_secret_arn
}

resource "aws_secretsmanager_secret_rotation" "rabbitmq_credentials" {
  count = local.rabbitmq_rotation_enabled ? 1 : 0

  secret_id           = local.lambda_secret_arn
  rotation_lambda_arn = module.rabbitmq_rotation_lambda[0].function_arn

  rotation_rules {
    automatically_after_days = var.rabbitmq_credentials_rotation_days
  }

  rotate_immediately = true

  depends_on = [aws_lambda_permission.allow_secretsmanager_rotation]
}
