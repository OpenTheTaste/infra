module "s3_media" {
  source = "../../modules/s3_media"

  bucket_name           = local.media_bucket_name
  force_destroy         = var.media_force_destroy
  enable_lifecycle_rule = var.media_enable_lifecycle_rule
  enable_cors           = var.media_enable_cors
  cors_allowed_origins  = var.media_cors_allowed_origins

  tags = local.common_tags
}

module "ecs_transcoder" {
  count  = var.enable_ecs_transcoder ? 1 : 0
  source = "../../modules/ecs_transcoder"

  name_prefix = "${var.project}-${var.environment}"
  aws_region  = data.aws_region.current.region
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids

  container_image    = var.ecs_transcoder_container_image
  task_cpu           = var.ecs_transcoder_task_cpu
  task_memory        = var.ecs_transcoder_task_memory
  desired_count      = var.ecs_transcoder_desired_count
  log_retention_days = var.ecs_transcoder_log_retention_days

  container_environment = merge(
    {
      ENV          = var.environment
      PROJECT      = var.project
      MEDIA_BUCKET = module.s3_media.bucket_name
    },
    var.ecs_transcoder_container_environment
  )

  s3_bucket_arns = [module.s3_media.bucket_arn]

  tags = local.common_tags
}

resource "random_password" "lambda_rabbitmq" {
  count = var.enable_lambda_worker && var.lambda_rabbitmq_credentials_secret_arn == null && var.create_lambda_rabbitmq_credentials_secret ? 1 : 0

  length           = var.lambda_rabbitmq_password_length
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}<>?"
}

resource "aws_secretsmanager_secret" "lambda_rabbitmq_credentials" {
  count = var.enable_lambda_worker && var.lambda_rabbitmq_credentials_secret_arn == null && var.create_lambda_rabbitmq_credentials_secret ? 1 : 0

  name = coalesce(var.lambda_rabbitmq_secret_name, "${var.project}/${var.environment}/rabbitmq/credentials")
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "lambda_rabbitmq_credentials" {
  count = var.enable_lambda_worker && var.lambda_rabbitmq_credentials_secret_arn == null && var.create_lambda_rabbitmq_credentials_secret ? 1 : 0

  secret_id     = aws_secretsmanager_secret.lambda_rabbitmq_credentials[0].id
  secret_string = jsonencode({ username = var.lambda_rabbitmq_username, password = random_password.lambda_rabbitmq[0].result })
}

resource "random_password" "rabbitmq_admin" {
  count = var.enable_rabbitmq_credentials_rotation && var.rabbitmq_admin_credentials_secret_arn == null && var.create_rabbitmq_admin_credentials_secret ? 1 : 0

  length           = var.rabbitmq_admin_password_length
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}<>?"
}

resource "aws_secretsmanager_secret" "rabbitmq_admin_credentials" {
  count = var.enable_rabbitmq_credentials_rotation && var.rabbitmq_admin_credentials_secret_arn == null && var.create_rabbitmq_admin_credentials_secret ? 1 : 0

  name = coalesce(var.rabbitmq_admin_secret_name, "${var.project}/${var.environment}/rabbitmq/admin-credentials")
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "rabbitmq_admin_credentials" {
  count = var.enable_rabbitmq_credentials_rotation && var.rabbitmq_admin_credentials_secret_arn == null && var.create_rabbitmq_admin_credentials_secret ? 1 : 0

  secret_id     = aws_secretsmanager_secret.rabbitmq_admin_credentials[0].id
  secret_string = jsonencode({ username = var.rabbitmq_admin_username, password = random_password.rabbitmq_admin[0].result })
}

resource "random_password" "monitoring_grafana_admin" {
  count = var.enable_monitoring && var.monitoring_grafana_admin_secret_arn == null && var.create_monitoring_grafana_admin_secret ? 1 : 0

  length           = var.monitoring_grafana_admin_password_length
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}<>?"
}

resource "aws_secretsmanager_secret" "monitoring_grafana_admin_credentials" {
  count = var.enable_monitoring && var.monitoring_grafana_admin_secret_arn == null && var.create_monitoring_grafana_admin_secret ? 1 : 0

  name = coalesce(var.monitoring_grafana_admin_secret_name, "${var.project}/${var.environment}/monitoring/grafana-admin-credentials")
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "monitoring_grafana_admin_credentials" {
  count = var.enable_monitoring && var.monitoring_grafana_admin_secret_arn == null && var.create_monitoring_grafana_admin_secret ? 1 : 0

  secret_id     = aws_secretsmanager_secret.monitoring_grafana_admin_credentials[0].id
  secret_string = jsonencode({ username = var.monitoring_grafana_admin_user, password = random_password.monitoring_grafana_admin[0].result })
}

module "lambda_parameters" {
  count  = var.enable_lambda_worker ? 1 : 0
  source = "../../modules/parameter_store"

  name_prefix = local.lambda_parameter_prefix
  parameters  = local.lambda_runtime_parameters

  tags = local.common_tags
}

module "app_ec2_iam" {
  source = "../../modules/iam"

  role_name = "${var.project}-${var.environment}-ec2-app"
  create_inline_policy = false

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  allow_ssm_parameter_read   = true
  allow_secrets_manager_read = false
  secret_arns                = []
  ssm_parameter_arns         = values(module.app_service_env_parameters.parameter_arns)

  tags = local.common_tags
}

module "rabbitmq_ec2_iam" {
  source = "../../modules/iam"

  role_name = "${var.project}-${var.environment}-ec2-rabbitmq"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  allow_ssm_parameter_read   = false
  allow_secrets_manager_read = length(local.rabbitmq_bootstrap_secret_arns) > 0
  secret_arns                = local.rabbitmq_bootstrap_secret_arns
  ssm_parameter_arns         = []

  tags = local.common_tags
}

module "monitoring_ec2_iam" {
  count  = var.enable_monitoring ? 1 : 0
  source = "../../modules/iam"

  role_name = "${var.project}-${var.environment}-ec2-monitoring"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  allow_ssm_parameter_read   = false
  allow_secrets_manager_read = length(local.monitoring_secret_arns) > 0
  secret_arns                = local.monitoring_secret_arns
  ssm_parameter_arns         = []

  tags = local.common_tags
}

module "app_service_env_parameters" {
  source = "../../modules/parameter_store"

  name_prefix = local.service_env_parameter_prefix
  parameters = {
    "api-user/env"  = var.api_user_env_parameter_value
    "api-admin/env" = var.api_admin_env_parameter_value
    "machine/env"   = var.machine_env_parameter_value
  }

  tags = local.common_tags
}

module "lambda_iam" {
  count  = var.enable_lambda_worker ? 1 : 0
  source = "../../modules/iam"

  role_name = "${var.project}-${var.environment}-lambda-worker"

  assume_role_service_principals = ["lambda.amazonaws.com"]
  create_instance_profile        = false
  create_inline_policy           = true
  allow_ssm_parameter_read       = true
  allow_ssm_parameter_write      = true
  allow_secrets_manager_read     = true
  allow_ecs_service_scale        = local.lambda_ecs_service_arn != null
  ssm_parameter_arns             = values(module.lambda_parameters[0].parameter_arns)
  ssm_parameter_write_arns       = [module.lambda_parameters[0].parameter_arns["last_scale_epoch"]]
  secret_arns                    = [local.lambda_secret_arn]
  ecs_service_arns               = local.lambda_ecs_service_arn == null ? [] : [local.lambda_ecs_service_arn]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]

  tags = local.common_tags
}

module "rabbitmq_rotation_lambda_iam" {
  count  = local.rabbitmq_rotation_enabled ? 1 : 0
  source = "../../modules/iam"

  role_name = "${var.project}-${var.environment}-rabbitmq-rotation-lambda"

  assume_role_service_principals = ["lambda.amazonaws.com"]
  create_instance_profile        = false
  create_inline_policy           = true
  allow_ssm_parameter_read       = false
  allow_ssm_parameter_write      = false
  allow_secrets_manager_read     = true
  allow_secrets_manager_rotation = true
  allow_ecs_service_scale        = false
  secret_arns                    = compact([local.rabbitmq_admin_secret_arn, local.lambda_secret_arn])
  secret_rotation_arns           = compact([local.lambda_secret_arn])

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]

  tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  identifier        = "${var.project}-${var.environment}-db"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.rds_sg_id

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t4g.micro"
  db_name        = "oplust"

  username                    = "app_admin"
  manage_master_user_password = true

  port = 3306

  tags = local.common_tags
}
