variable "name" {
  description = "Name tag prefix for monitoring instance."
  type        = string
  default     = "monitoring"
}

variable "subnet_id" {
  description = "Subnet ID where monitoring instance is created."
  type        = string
}

variable "security_group_id" {
  description = "Security group ID attached to monitoring instance."
  type        = string
}

variable "ami_id" {
  description = "AMI ID used for monitoring instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for monitoring server."
  type        = string
  default     = "t3.small"
}

variable "iam_instance_profile_name" {
  description = "Optional IAM instance profile name."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Associate public IP to instance."
  type        = bool
  default     = false
}

variable "enable_detailed_monitoring" {
  description = "Enable EC2 detailed monitoring."
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 40
}

variable "root_volume_type" {
  description = "Root EBS volume type."
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Encrypt root EBS volume."
  type        = bool
  default     = true
}

variable "grafana_admin_user" {
  description = "Grafana admin username."
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana admin password."
  type        = string
  sensitive   = true
  default     = null
}

variable "grafana_admin_secret_arn" {
  description = "Optional Secrets Manager ARN containing Grafana admin credentials JSON (username/password)."
  type        = string
  default     = null
}

variable "prometheus_scrape_targets" {
  description = "Additional Prometheus scrape targets."
  type = list(object({
    target       = string
    metrics_path = string
  }))
  default = []
}

variable "user_data" {
  description = "Optional user_data override."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default     = {}
}
