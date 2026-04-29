variable "name_prefix" {
  description = "Prefix used for Lambda naming."
  type        = string
}

variable "function_name_suffix" {
  description = "Lambda function name suffix."
  type        = string
  default     = "worker"
}

variable "description" {
  description = "Lambda function description."
  type        = string
  default     = "Scheduled worker lambda"
}

variable "role_arn" {
  description = "Existing IAM role ARN for Lambda execution."
  type        = string
}

variable "package_file" {
  description = "Path to the zipped Lambda deployment package."
  type        = string
}

variable "handler" {
  description = "Lambda handler string."
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "python3.12"
}

variable "architectures" {
  description = "Lambda instruction set architectures."
  type        = list(string)
  default     = ["x86_64"]
}

variable "memory_size" {
  description = "Lambda memory size (MB)."
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Lambda timeout (seconds)."
  type        = number
  default     = 30
}

variable "publish" {
  description = "Whether to publish a new function version on update."
  type        = bool
  default     = false
}

variable "environment_variables" {
  description = "Environment variables for Lambda."
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "Subnet IDs for Lambda VPC config."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "subnet_ids must contain at least one subnet."
  }
}

variable "security_group_ids" {
  description = "Security group IDs for Lambda VPC config."
  type        = list(string)

  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "security_group_ids must contain at least one security group."
  }
}

variable "log_retention_days" {
  description = "CloudWatch Log Group retention days."
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
