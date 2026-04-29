variable "name_prefix" {
  description = "Prefix used for EventBridge rule naming."
  type        = string
}

variable "enabled" {
  description = "Whether to create the schedule rule and target."
  type        = bool
  default     = false
}

variable "rule_name" {
  description = "EventBridge rule name suffix."
  type        = string
  default     = "lambda-every-minute"
}

variable "schedule_expression" {
  description = "EventBridge schedule expression."
  type        = string
  default     = "rate(1 minute)"
}

variable "lambda_target_arn" {
  description = "Lambda function ARN used as EventBridge target."
  type        = string
  default     = null

  validation {
    condition     = var.enabled ? var.lambda_target_arn != null : true
    error_message = "lambda_target_arn is required when enabled is true."
  }
}

variable "lambda_function_name" {
  description = "Lambda function name (or ARN) for aws_lambda_permission."
  type        = string
  default     = null

  validation {
    condition     = var.enabled ? var.lambda_function_name != null : true
    error_message = "lambda_function_name is required when enabled is true."
  }
}

variable "tags" {
  description = "Additional tags for EventBridge resources."
  type        = map(string)
  default     = {}
}
