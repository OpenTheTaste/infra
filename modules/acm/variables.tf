variable "domain_name" {
  description = "Primary domain name for ACM certificate."
  type        = string
}

variable "subject_alternative_names" {
  description = "Optional SAN entries for ACM certificate."
  type        = list(string)
  default     = []
}

variable "zone_id" {
  description = "Route53 hosted zone ID used for DNS validation records."
  type        = string
}

variable "tags" {
  description = "Additional tags for ACM resources."
  type        = map(string)
  default     = {}
}
