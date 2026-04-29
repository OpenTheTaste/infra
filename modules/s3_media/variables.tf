variable "bucket_name" {
  description = "Unique S3 bucket name for media storage."
  type        = string
}

variable "force_destroy" {
  description = "Delete all objects when destroying the bucket."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable S3 versioning."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "sse_algorithm must be either AES256 or aws:kms."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN when sse_algorithm is aws:kms."
  type        = string
  default     = null

  validation {
    condition     = var.sse_algorithm == "aws:kms" ? var.kms_key_arn != null : true
    error_message = "kms_key_arn is required when sse_algorithm is aws:kms."
  }
}

variable "bucket_key_enabled" {
  description = "Enable S3 Bucket Key for KMS encryption."
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "Block public ACLs."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policy."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies."
  type        = bool
  default     = true
}

variable "enable_lifecycle_rule" {
  description = "Enable default lifecycle rule for media objects."
  type        = bool
  default     = false
}

variable "enable_cors" {
  description = "Enable CORS configuration for browser uploads/downloads."
  type        = bool
  default     = false
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS."
  type        = list(string)
  default     = []
}

variable "cors_allowed_methods" {
  description = "Allowed HTTP methods for CORS."
  type        = list(string)
  default     = ["GET", "PUT", "POST", "HEAD"]
}

variable "cors_allowed_headers" {
  description = "Allowed request headers for CORS."
  type        = list(string)
  default     = ["*"]
}

variable "cors_expose_headers" {
  description = "Response headers to expose to browsers."
  type        = list(string)
  default     = ["ETag"]
}

variable "cors_max_age_seconds" {
  description = "How long browsers cache CORS preflight response."
  type        = number
  default     = 300
}

variable "transition_to_standard_ia_days" {
  description = "Days after creation to transition objects to STANDARD_IA."
  type        = number
  default     = null
}

variable "transition_to_glacier_days" {
  description = "Days after creation to transition objects to GLACIER."
  type        = number
  default     = null
}

variable "expiration_days" {
  description = "Days after creation to expire current objects."
  type        = number
  default     = null
}

variable "noncurrent_expiration_days" {
  description = "Days to expire noncurrent object versions."
  type        = number
  default     = null
}

variable "tags" {
  description = "Additional tags for S3 resources."
  type        = map(string)
  default     = {}
}
