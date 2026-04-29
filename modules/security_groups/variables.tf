variable "name_prefix" {
  description = "Prefix used for SG naming."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups are created."
  type        = string
}

variable "admin_port" {
  description = "Admin application port."
  type        = number
  default     = 8081
}

variable "user_port" {
  description = "User application port."
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Database port."
  type        = number
  default     = 3306
}

variable "rabbitmq_amqp_port" {
  description = "RabbitMQ AMQP port."
  type        = number
  default     = 5672
}

variable "rabbitmq_management_port" {
  description = "RabbitMQ management UI port."
  type        = number
  default     = 15672
}

variable "monitoring_ports" {
  description = "Monitoring service ports exposed by monitoring EC2."
  type        = list(number)
  default     = [3000, 9090, 3100]
}

variable "alb_http_ingress_cidrs" {
  description = "CIDRs allowed to access ALB HTTP."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_https_ingress_cidrs" {
  description = "CIDRs allowed to access ALB HTTPS."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional tags for security groups."
  type        = map(string)
  default     = {}
}
