terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  common_tags = merge(
    {
      Name      = var.name
      ManagedBy = "terraform"
      Component = "rabbitmq"
    },
    var.tags
  )

  resolved_user_data = var.user_data != null ? var.user_data : (
    var.bootstrap_from_secrets ? templatefile("${path.module}/templates/bootstrap_from_secrets.sh.tftpl", {
      rabbitmq_admin_credentials_secret_arn = var.rabbitmq_admin_credentials_secret_arn
      rabbitmq_app_credentials_secret_arn   = var.rabbitmq_app_credentials_secret_arn
      rabbitmq_app_user_tags                = var.rabbitmq_app_user_tags
    }) : null
  )
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile_name
  associate_public_ip_address = var.associate_public_ip
  monitoring                  = var.enable_detailed_monitoring
  vpc_security_group_ids      = [var.security_group_id]

  user_data = local.resolved_user_data

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_volume_encrypted
    delete_on_termination = true
  }

  tags = local.common_tags

  lifecycle {
    precondition {
      condition     = var.bootstrap_from_secrets ? (var.rabbitmq_admin_credentials_secret_arn != null && var.rabbitmq_app_credentials_secret_arn != null) : true
      error_message = "rabbitmq_admin_credentials_secret_arn and rabbitmq_app_credentials_secret_arn are required when bootstrap_from_secrets is true."
    }
  }
}
