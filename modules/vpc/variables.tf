variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones used to create subnets."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) > 0
    error_message = "availability_zones must contain at least one AZ."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (same length as availability_zones)."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "public_subnet_cidrs length must match availability_zones length."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (same length as availability_zones)."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.availability_zones)
    error_message = "private_subnet_cidrs length must match availability_zones length."
  }
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateway(s) for private subnet outbound internet."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Create one shared NAT gateway for all private subnets when true."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
