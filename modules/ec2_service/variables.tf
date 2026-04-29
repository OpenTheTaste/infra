variable "name" {
  description = "Service name used for resource naming and tags."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the service security group is created."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance is created."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = null
}

variable "iam_instance_profile_name" {
  description = "Optional IAM instance profile name attached to instance."
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Whether instance gets a public IP."
  type        = bool
  default     = false
}

variable "security_group_id" {
  description = "Existing primary security group ID to attach. When null, this module creates one."
  type        = string
  default     = null
}

variable "additional_security_group_ids" {
  description = "Additional security groups to attach to instance."
  type        = list(string)
  default     = []
}

variable "ingress_rules" {
  description = "Ingress rules for the module-managed service security group. Ignored when security_group_id is set."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string)
  }))
  default = []
}

variable "user_data" {
  description = "Optional plain-text user_data script."
  type        = string
  default     = null
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for the EC2 instance."
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Root EBS volume size (GiB)."
  type        = number
  default     = 30
}

variable "root_volume_type" {
  description = "Root EBS volume type."
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Whether root EBS volume is encrypted."
  type        = bool
  default     = true
}

variable "target_group_attachments" {
  description = "Optional target group attachments for this instance."
  type = list(object({
    target_group_arn = string
    port             = optional(number)
  }))
  default = []
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
