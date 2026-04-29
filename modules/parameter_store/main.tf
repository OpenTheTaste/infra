terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  normalized_prefix = startswith(var.name_prefix, "/") ? trimsuffix(var.name_prefix, "/") : "/${trim(var.name_prefix, "/")}"

  common_tags = merge(
    {
      ManagedBy = "terraform"
      Component = "parameter_store"
    },
    var.tags
  )
}

resource "aws_ssm_parameter" "this" {
  for_each = var.parameters

  name  = "${local.normalized_prefix}/${each.key}"
  type  = var.parameter_type
  tier  = var.tier
  value = each.value

  tags = merge(local.common_tags, { Name = each.key })
}
