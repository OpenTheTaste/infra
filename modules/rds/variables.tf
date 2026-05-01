variable "identifier" {
  description = "RDS instance identifier."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where DB security group is created."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for DB subnet group."
  type        = list(string)
}

variable "security_group_id" {
  description = "Existing primary DB security group ID to attach. When null, this module creates one."
  type        = string
  default     = null
}

variable "create_security_group" {
  description = "Whether this module should create a DB security group. When false, security_group_id should be provided by caller."
  type        = bool
  default     = false
}

variable "engine" {
  description = "Database engine (postgres, mysql, mariadb, etc.)."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version."
  type        = string
  default     = "16.3"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = null
}

variable "username" {
  description = "Master username."
  type        = string
}

variable "password" {
  description = "Master password (required when manage_master_user_password is false)."
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.manage_master_user_password ? true : var.password != null
    error_message = "password must be set when manage_master_user_password is false."
  }
}

variable "manage_master_user_password" {
  description = "Let RDS manage master password in AWS Secrets Manager."
  type        = bool
  default     = false
}

variable "allocated_storage" {
  description = "Initial storage size in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage autoscaling in GiB."
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type (gp3, gp2, io1, etc.)."
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Whether storage is encrypted."
  type        = bool
  default     = true
}

variable "port" {
  description = "Database port."
  type        = number
  default     = 5432
}

variable "publicly_accessible" {
  description = "Whether DB has a public endpoint."
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period in days."
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window (UTC)."
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "Preferred maintenance window (UTC)."
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Enable deletion protection for DB instance."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy."
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply modifications immediately."
  type        = bool
  default     = false
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to access DB port for module-managed SG. Ignored when security_group_id is set."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access DB port for module-managed SG. Ignored when security_group_id is set."
  type        = list(string)
  default     = []
}

variable "additional_security_group_ids" {
  description = "Additional security groups attached to DB instance."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for resources."
  type        = map(string)
  default     = {}
}
