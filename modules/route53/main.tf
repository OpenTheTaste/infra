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
  zone_id = var.create_hosted_zone ? aws_route53_zone.this[0].zone_id : var.existing_zone_id

  common_tags = merge(
    {
      Name      = var.domain_name
      ManagedBy = "terraform"
      Component = "route53"
    },
    var.tags
  )
}

resource "aws_route53_zone" "this" {
  count = var.create_hosted_zone ? 1 : 0

  name = var.domain_name
  tags = local.common_tags
}

resource "aws_route53_record" "apex" {
  count = var.create_alias_records ? 1 : 0

  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "admin" {
  count = var.create_alias_records && var.create_admin_record ? 1 : 0

  zone_id = local.zone_id
  name    = "${var.admin_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
