variable "role_name" {
  description = "IAM role name."
  type        = string
}

variable "instance_profile_name" {
  description = "Optional IAM instance profile name."
  type        = string
  default     = null
}

variable "assume_role_service_principals" {
  description = "AWS service principals that can assume this role."
  type        = list(string)
  default     = ["ec2.amazonaws.com"]
}

variable "managed_policy_arns" {
  description = "Managed policy ARNs to attach to role."
  type        = list(string)
  default     = []
}

variable "create_instance_profile" {
  description = "Create IAM instance profile for EC2 attachment."
  type        = bool
  default     = true
}

variable "create_inline_policy" {
  description = "Create inline least-privilege policy."
  type        = bool
  default     = true
}

variable "allow_ssm_parameter_read" {
  description = "Allow reading SSM Parameters."
  type        = bool
  default     = true
}

variable "ssm_parameter_arns" {
  description = "Allowed SSM Parameter ARNs."
  type        = list(string)
  default     = ["*"]
}

variable "allow_ssm_parameter_write" {
  description = "Allow writing SSM Parameters."
  type        = bool
  default     = false
}

variable "ssm_parameter_write_arns" {
  description = "Allowed SSM Parameter ARNs for write."
  type        = list(string)
  default     = []
}

variable "allow_secrets_manager_read" {
  description = "Allow reading Secrets Manager secrets."
  type        = bool
  default     = true
}

variable "secret_arns" {
  description = "Allowed Secrets Manager secret ARNs."
  type        = list(string)
  default     = ["*"]
}

variable "allow_secrets_manager_rotation" {
  description = "Allow Secrets Manager rotation management actions."
  type        = bool
  default     = false
}

variable "secret_rotation_arns" {
  description = "Allowed Secrets Manager secret ARNs for rotation management."
  type        = list(string)
  default     = []
}

variable "allow_kms_decrypt" {
  description = "Allow kms:Decrypt for secret decryption."
  type        = bool
  default     = false
}

variable "kms_key_arns" {
  description = "Allowed KMS key ARNs for decrypt."
  type        = list(string)
  default     = []
}

variable "allow_ecs_service_scale" {
  description = "Allow ECS service describe/update for scaling."
  type        = bool
  default     = false
}

variable "ecs_service_arns" {
  description = "Allowed ECS service ARNs for scaling actions."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for IAM resources."
  type        = map(string)
  default     = {}
}
