variable "owners" {
  description = "AMI owner account IDs or aliases (e.g. amazon)."
  type        = list(string)
  default     = ["amazon"]
}

variable "name_patterns" {
  description = "AMI name patterns used in the name filter."
  type        = list(string)
}

variable "extra_filters" {
  description = "Additional aws_ami filters."
  type = list(object({
    name   = string
    values = list(string)
  }))
  default = []
}
