terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Select latest AMI by owner and name filter.
data "aws_ami" "selected" {
  most_recent = true
  owners      = var.owners

  filter {
    name   = "name"
    values = var.name_patterns
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  dynamic "filter" {
    for_each = var.extra_filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}
