variable "project" {
  description = "Project name used for resource naming and tags."
  type        = string
  default     = "oplust"
}

variable "environment" {
  description = "Environment label for tags."
  type        = string
  default     = "global"
}

variable "state_bucket_name" {
  description = "Optional explicit S3 bucket name for Terraform state."
  type        = string
  default     = null
}

variable "state_bucket_name_prefix" {
  description = "Prefix used when state_bucket_name is null. Final name adds account and region."
  type        = string
  default     = "oplust-tfstate"
}

variable "force_destroy_bucket" {
  description = "Force delete state bucket and all objects on destroy. Keep false in normal operation."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default     = {}
}
