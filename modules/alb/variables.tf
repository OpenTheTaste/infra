variable "name" {
  description = "ALB name (max 32 chars, unique per region/account)."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ALB and target groups are created."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for ALB (typically public subnets)."
  type        = list(string)
}

variable "alb_security_group_ids" {
  description = "Existing security group IDs to attach to ALB. When empty, this module creates one SG."
  type        = list(string)
  default     = []
}

variable "internal" {
  description = "Whether ALB is internal."
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on ALB."
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "ALB idle timeout seconds."
  type        = number
  default     = 60
}

variable "http_ingress_cidrs" {
  description = "Allowed source CIDRs for HTTP(80)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "https_ingress_cidrs" {
  description = "Allowed source CIDRs for HTTPS(443)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_https" {
  description = "Enable HTTPS listener."
  type        = bool
  default     = false
}

variable "redirect_http_to_https" {
  description = "Redirect HTTP to HTTPS when HTTPS is enabled."
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener. Required when enable_https=true."
  type        = string
  default     = null

  validation {
    condition     = var.enable_https ? var.certificate_arn != null : true
    error_message = "certificate_arn is required when enable_https is true."
  }
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "target_groups" {
  description = "Target groups keyed by logical name."
  type = map(object({
    port        = number
    protocol    = string
    target_type = optional(string)
    health_check = optional(object({
      path                = optional(string)
      matcher             = optional(string)
      interval            = optional(number)
      timeout             = optional(number)
      healthy_threshold   = optional(number)
      unhealthy_threshold = optional(number)
    }))
  }))
}

variable "default_target_group" {
  description = "Target group key used as default listener action."
  type        = string

  validation {
    condition     = contains(keys(var.target_groups), var.default_target_group)
    error_message = "default_target_group must be one of target_groups keys."
  }
}

variable "listener_rules" {
  description = "Optional listener routing rules (host/path based)."
  type = list(object({
    priority         = number
    target_group_key = string
    host_headers     = optional(list(string), [])
    path_patterns    = optional(list(string), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.listener_rules : contains(keys(var.target_groups), r.target_group_key)
    ])
    error_message = "Every listener rule target_group_key must exist in target_groups."
  }

  validation {
    condition = alltrue([
      for r in var.listener_rules : (length(r.host_headers) + length(r.path_patterns)) > 0
    ])
    error_message = "Each listener rule must include at least one host_headers or path_patterns condition."
  }

  validation {
    condition = length(distinct([
      for r in var.listener_rules : r.priority
    ])) == length(var.listener_rules)
    error_message = "Listener rule priorities must be unique."
  }
}

variable "tags" {
  description = "Additional tags applied to ALB resources."
  type        = map(string)
  default     = {}
}
