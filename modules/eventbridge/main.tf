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
      ManagedBy = "terraform"
      Component = "eventbridge"
    },
    var.tags
  )
}

resource "aws_cloudwatch_event_rule" "this" {
  count = var.enabled ? 1 : 0

  name                = substr("${var.name_prefix}-${var.rule_name}", 0, 64)
  description         = "Trigger Lambda by schedule"
  event_bus_name      = "default"
  schedule_expression = var.schedule_expression
  state               = "ENABLED"

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-${var.rule_name}" })
}

resource "aws_cloudwatch_event_target" "this" {
  count = var.enabled ? 1 : 0

  event_bus_name = "default"
  rule           = aws_cloudwatch_event_rule.this[0].name
  arn            = var.lambda_target_arn
  target_id      = "lambda-target"
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count = var.enabled ? 1 : 0

  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this[0].arn
}
