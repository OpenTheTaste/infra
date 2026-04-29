terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = var.assume_role_service_principals
    }
  }
}

data "aws_iam_policy_document" "inline" {
  dynamic "statement" {
    for_each = var.allow_ssm_parameter_read ? [1] : []
    content {
      sid = "ReadSsmParameters"
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ]
      resources = var.ssm_parameter_arns
    }
  }

  dynamic "statement" {
    for_each = var.allow_ssm_parameter_write ? [1] : []
    content {
      sid = "WriteSsmParameters"
      actions = [
        "ssm:PutParameter"
      ]
      resources = var.ssm_parameter_write_arns
    }
  }

  dynamic "statement" {
    for_each = var.allow_secrets_manager_read ? [1] : []
    content {
      sid = "ReadSecretsManager"
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      resources = var.secret_arns
    }
  }

  dynamic "statement" {
    for_each = var.allow_secrets_manager_rotation ? [1] : []
    content {
      sid = "ManageSecretRotation"
      actions = [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecretVersionStage"
      ]
      resources = var.secret_rotation_arns
    }
  }

  dynamic "statement" {
    for_each = var.allow_secrets_manager_rotation ? [1] : []
    content {
      sid       = "GetRandomPassword"
      actions   = ["secretsmanager:GetRandomPassword"]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = var.allow_kms_decrypt ? [1] : []
    content {
      sid       = "DecryptKms"
      actions   = ["kms:Decrypt"]
      resources = var.kms_key_arns
    }
  }

  dynamic "statement" {
    for_each = var.allow_ecs_service_scale ? [1] : []
    content {
      sid = "ScaleEcsService"
      actions = [
        "ecs:DescribeServices",
        "ecs:UpdateService"
      ]
      resources = var.ecs_service_arns
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  count = var.create_inline_policy ? 1 : 0

  name   = "${var.role_name}-inline"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.inline.json
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = var.instance_profile_name == null ? "${var.role_name}-profile" : var.instance_profile_name
  role = aws_iam_role.this.name
  tags = var.tags
}
