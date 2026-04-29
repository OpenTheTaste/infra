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
  function_name = substr("${var.name_prefix}-${var.function_name_suffix}", 0, 64)

  common_tags = merge(
    {
      ManagedBy = "terraform"
      Component = "lambda"
    },
    var.tags
  )
}

resource "aws_lambda_function" "this" {
  function_name = local.function_name
  description   = var.description
  role          = var.role_arn

  filename         = var.package_file
  source_code_hash = filebase64sha256(var.package_file)

  handler       = var.handler
  runtime       = var.runtime
  architectures = var.architectures
  memory_size   = var.memory_size
  timeout       = var.timeout
  publish       = var.publish

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = var.environment_variables
  }

  tags = merge(local.common_tags, { Name = local.function_name })
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}
