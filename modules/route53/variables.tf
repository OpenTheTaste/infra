variable "domain_name" {
  description = "Base domain managed in Route53 (e.g. example.cloud)."
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name used in alias records."
  type        = string
  default     = null
}

variable "alb_zone_id" {
  description = "ALB canonical hosted zone ID used in alias records."
  type        = string
  default     = null
}

variable "admin_subdomain" {
  description = "Admin subdomain label."
  type        = string
  default     = "admin"
}

variable "create_hosted_zone" {
  description = "Create hosted zone for domain_name when true."
  type        = bool
  default     = true
}

variable "existing_zone_id" {
  description = "Existing hosted zone ID. Required when create_hosted_zone is false."
  type        = string
  default     = null

  validation {
    condition     = var.create_hosted_zone ? true : var.existing_zone_id != null
    error_message = "existing_zone_id must be set when create_hosted_zone is false."
  }
}

variable "create_admin_record" {
  description = "Create admin subdomain A alias record."
  type        = bool
  default     = true
}

variable "create_alias_records" {
  description = "Create apex/admin ALB alias records."
  type        = bool
  default     = false

  validation {
    condition     = var.create_alias_records ? (var.alb_dns_name != null && var.alb_zone_id != null) : true
    error_message = "alb_dns_name and alb_zone_id are required when create_alias_records is true."
  }
}

variable "tags" {
  description = "Additional tags applied to hosted zone when created."
  type        = map(string)
  default     = {}
}
