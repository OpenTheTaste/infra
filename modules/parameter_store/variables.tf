variable "name_prefix" {
  description = "Path prefix for parameter names. Example: /oplust/dev/lambda/worker"
  type        = string
}

variable "parameters" {
  description = "Map of parameter key => value."
  type        = map(string)
}

variable "parameter_type" {
  description = "SSM parameter type."
  type        = string
  default     = "String"

  validation {
    condition     = contains(["String", "StringList", "SecureString"], var.parameter_type)
    error_message = "parameter_type must be one of: String, StringList, SecureString."
  }
}

variable "tier" {
  description = "SSM parameter tier."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Advanced", "Intelligent-Tiering"], var.tier)
    error_message = "tier must be one of: Standard, Advanced, Intelligent-Tiering."
  }
}

variable "tags" {
  description = "Tags applied to parameters."
  type        = map(string)
  default     = {}
}
