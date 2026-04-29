module "route53_zone" {
  source = "../../modules/route53"

  domain_name          = var.base_domain
  admin_subdomain      = var.admin_subdomain
  create_hosted_zone   = var.route53_create_hosted_zone
  existing_zone_id     = var.route53_existing_zone_id
  create_alias_records = false

  tags = local.common_tags
}

module "acm" {
  source = "../../modules/acm"

  domain_name               = var.base_domain
  subject_alternative_names = [local.admin_host]
  zone_id                   = module.route53_zone.zone_id

  tags = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  name                   = "${var.project}-${var.environment}-alb"
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.public_subnet_ids
  alb_security_group_ids = [module.security_groups.alb_sg_id]

  enable_https    = true
  certificate_arn = module.acm.certificate_arn

  target_groups = {
    admin = {
      port     = 8081
      protocol = "HTTP"
      health_check = {
        path = "/health"
      }
    }
    user = {
      port     = 8080
      protocol = "HTTP"
    }
  }

  default_target_group = "user"

  listener_rules = [
    {
      priority         = 10
      target_group_key = "admin"
      host_headers     = [local.admin_host]
    }
  ]

  tags = local.common_tags
}

module "route53_alias" {
  source = "../../modules/route53"

  domain_name          = var.base_domain
  admin_subdomain      = var.admin_subdomain
  create_hosted_zone   = false
  existing_zone_id     = module.route53_zone.zone_id
  create_alias_records = true
  alb_dns_name         = module.alb.alb_dns_name
  alb_zone_id          = module.alb.alb_zone_id

  tags = local.common_tags
}

module "acm_cloudfront" {
  count  = var.enable_cloudfront && var.media_cloudfront_use_custom_domain && var.media_cloudfront_acm_certificate_arn == null ? 1 : 0
  source = "../../modules/acm"

  providers = {
    aws = aws.us_east_1
  }

  domain_name = local.media_host
  zone_id     = module.route53_zone.zone_id

  tags = local.common_tags
}

module "cloudfront" {
  count  = var.enable_cloudfront ? 1 : 0
  source = "../../modules/cloudfront"

  enabled                        = var.enable_cloudfront
  name_prefix                    = "${var.project}-${var.environment}"
  s3_bucket_name                 = module.s3_media.bucket_name
  s3_bucket_arn                  = module.s3_media.bucket_arn
  s3_bucket_regional_domain_name = module.s3_media.bucket_regional_domain_name

  aliases             = var.media_cloudfront_use_custom_domain ? [local.media_host] : []
  acm_certificate_arn = var.media_cloudfront_use_custom_domain ? coalesce(var.media_cloudfront_acm_certificate_arn, try(module.acm_cloudfront[0].certificate_arn, null)) : null
  price_class         = var.media_cloudfront_price_class

  create_route53_alias_record = var.media_cloudfront_use_custom_domain
  route53_zone_id             = module.route53_zone.zone_id
  route53_record_name         = local.media_host

  enable_signed_cookies         = var.media_cloudfront_enable_signed_cookies
  signed_cookies_public_key_pem = var.media_cloudfront_public_key_pem
  trusted_key_group_ids         = var.media_cloudfront_trusted_key_group_ids

  tags = local.common_tags
}

module "cloudfront_auth_parameters" {
  count  = var.enable_cloudfront && var.media_cloudfront_enable_signed_cookies && var.create_cloudfront_auth_parameters ? 1 : 0
  source = "../../modules/parameter_store"

  name_prefix = local.cloudfront_auth_parameter_prefix
  parameters = {
    distribution_domain_name    = module.cloudfront[0].distribution_domain_name
    trusted_key_group_ids       = join(",", var.media_cloudfront_trusted_key_group_ids)
    signed_cookie_public_key_id = var.cloudfront_signed_cookie_public_key_id
  }

  tags = local.common_tags
}
