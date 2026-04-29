variable "name" {
  description = "RabbitMQ EC2 instance name."
  type        = string
}

variable "subnet_id" {
  description = "Private subnet ID where RabbitMQ EC2 runs."
  type        = string
}

variable "security_group_id" {
  description = "Security group ID attached to RabbitMQ EC2."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for RabbitMQ EC2."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for RabbitMQ."
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = null
}

variable "iam_instance_profile_name" {
  description = "Optional IAM instance profile name."
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Whether RabbitMQ EC2 receives a public IP."
  type        = bool
  default     = false
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for EC2 instance."
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Root EBS volume size (GiB)."
  type        = number
  default     = 30
}

variable "root_volume_type" {
  description = "Root EBS volume type."
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Whether root EBS volume is encrypted."
  type        = bool
  default     = true
}

variable "user_data" {
  description = "Optional bootstrap script managed outside Terraform."
  type        = string
  default     = null
}

variable "bootstrap_from_secrets" {
  description = "When true, bootstrap RabbitMQ users from Secrets Manager during instance startup."
  type        = bool
  default     = false
}

variable "rabbitmq_admin_credentials_secret_arn" {
  description = "Secrets Manager ARN for RabbitMQ admin credentials JSON (username/password)."
  type        = string
  default     = null
}

variable "rabbitmq_app_credentials_secret_arn" {
  description = "Secrets Manager ARN for RabbitMQ app credentials JSON (username/password)."
  type        = string
  default     = null
}

variable "rabbitmq_app_user_tags" {
  description = "Tags applied to app user when bootstrapped (rabbitmqctl set_user_tags)."
  type        = string
  default     = "management"
}

variable "tags" {
  description = "Additional tags for resources."
  type        = map(string)
  default     = {}
}
