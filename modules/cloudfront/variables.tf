variable "enabled" {
  description = "Create CloudFront resources when true."
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Name prefix for CloudFront resources."
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name used as CloudFront origin."
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN used for bucket policy."
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "S3 bucket regional domain name used as CloudFront origin domain."
  type        = string
}

variable "price_class" {
  description = "CloudFront price class."
  type        = string
  default     = "PriceClass_100"
}

variable "aliases" {
  description = "Optional CNAME aliases for CloudFront distribution."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN in us-east-1 for CloudFront aliases."
  type        = string
  default     = null
}

variable "minimum_protocol_version" {
  description = "Minimum TLS version for viewers."
  type        = string
  default     = "TLSv1.2_2021"
}

variable "create_route53_alias_record" {
  description = "Create Route53 alias record to CloudFront when true."
  type        = bool
  default     = false
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID used for alias record."
  type        = string
  default     = null
}

variable "route53_record_name" {
  description = "Route53 record name (FQDN) for CloudFront alias."
  type        = string
  default     = null
}

variable "enable_signed_cookies" {
  description = "Attach trusted key groups to default cache behavior."
  type        = bool
  default     = false
}

variable "signed_cookies_public_key_pem" {
  description = "Optional PEM public key to create CloudFront public key and key group."
  type        = string
  default     = null
}

variable "trusted_key_group_ids" {
  description = "Existing CloudFront key group IDs trusted by distribution."
  type        = list(string)
  default     = []
}

variable "default_ttl" {
  description = "Default cache TTL in seconds."
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum cache TTL in seconds."
  type        = number
  default     = 86400
}

variable "min_ttl" {
  description = "Minimum cache TTL in seconds."
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags for CloudFront resources."
  type        = map(string)
  default     = {}
}
