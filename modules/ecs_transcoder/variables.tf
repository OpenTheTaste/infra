variable "name_prefix" {
  description = "Name prefix for ECS transcoder resources."
  type        = string
}

variable "aws_region" {
  description = "AWS region used for container logs."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for ECS service networking."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for ECS service tasks."
  type        = list(string)
}

variable "service_security_group_id" {
  description = "Optional existing security group ID for ECS service. If null, module creates one."
  type        = string
  default     = null
}

variable "container_name" {
  description = "Container name for transcoder task."
  type        = string
  default     = "transcoder"
}

variable "container_image" {
  description = "Container image for transcoder task."
  type        = string
}

variable "task_definition_family" {
  description = "Optional ECS task definition family override."
  type        = string
  default     = null
}

variable "container_environment" {
  description = "Environment variables for transcoder container."
  type        = map(string)
  default     = {}
}

variable "task_cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Fargate task memory (MiB)."
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Initial desired task count for ECS service."
  type        = number
  default     = 0
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for the service."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 7
}

variable "s3_bucket_arns" {
  description = "S3 bucket ARNs accessible by task role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for ECS resources."
  type        = map(string)
  default     = {}
}
