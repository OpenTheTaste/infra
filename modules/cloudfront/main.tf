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
  origin_id = "s3-${var.s3_bucket_name}"

  common_tags = merge(
    {
      ManagedBy = "terraform"
      Component = "cloudfront"
      Name      = "${var.name_prefix}-media-cdn"
    },
    var.tags
  )

  created_key_group_ids           = var.enabled && var.enable_signed_cookies && var.signed_cookies_public_key_pem != null ? [aws_cloudfront_key_group.this[0].id] : []
  effective_trusted_key_group_ids = var.enable_signed_cookies ? concat(var.trusted_key_group_ids, local.created_key_group_ids) : []
  use_custom_certificate          = length(var.aliases) > 0 && var.acm_certificate_arn != null
}

resource "aws_cloudfront_origin_access_control" "this" {
  count = var.enabled ? 1 : 0

  name                              = "${var.name_prefix}-media-oac"
  description                       = "OAC for ${var.s3_bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_public_key" "this" {
  count = var.enabled && var.enable_signed_cookies && var.signed_cookies_public_key_pem != null ? 1 : 0

  name        = "${var.name_prefix}-media-cookie-key"
  comment     = "Public key for signed cookies"
  encoded_key = var.signed_cookies_public_key_pem
}

resource "aws_cloudfront_key_group" "this" {
  count = var.enabled && var.enable_signed_cookies && var.signed_cookies_public_key_pem != null ? 1 : 0

  name    = "${var.name_prefix}-media-key-group"
  comment = "Trusted key group for signed cookies"
  items   = [aws_cloudfront_public_key.this[0].id]
}

resource "aws_cloudfront_distribution" "this" {
  count = var.enabled ? 1 : 0

  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.name_prefix} media distribution"
  price_class     = var.price_class
  aliases         = var.aliases

  origin {
    domain_name              = var.s3_bucket_regional_domain_name
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.this[0].id
  }

  default_cache_behavior {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    min_ttl     = var.min_ttl
    default_ttl = var.default_ttl
    max_ttl     = var.max_ttl

    trusted_key_groups = local.effective_trusted_key_group_ids

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = local.use_custom_certificate ? false : true
    acm_certificate_arn            = local.use_custom_certificate ? var.acm_certificate_arn : null
    ssl_support_method             = local.use_custom_certificate ? "sni-only" : null
    minimum_protocol_version       = local.use_custom_certificate ? var.minimum_protocol_version : "TLSv1"
  }

  tags = local.common_tags

  lifecycle {
    precondition {
      condition     = length(var.aliases) == 0 || var.acm_certificate_arn != null
      error_message = "acm_certificate_arn is required when aliases are set. CloudFront certificate must be in us-east-1."
    }

    precondition {
      condition     = !var.enable_signed_cookies || length(local.effective_trusted_key_group_ids) > 0
      error_message = "When enable_signed_cookies is true, provide signed_cookies_public_key_pem or trusted_key_group_ids."
    }
  }
}

data "aws_iam_policy_document" "s3_origin_access" {
  count = var.enabled ? 1 : 0

  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = ["${var.s3_bucket_arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this[0].arn]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_cloudfront" {
  count = var.enabled ? 1 : 0

  bucket = var.s3_bucket_name
  policy = data.aws_iam_policy_document.s3_origin_access[0].json
}

resource "aws_route53_record" "alias" {
  count = var.enabled && var.create_route53_alias_record ? 1 : 0

  zone_id = var.route53_zone_id
  name    = var.route53_record_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this[0].domain_name
    zone_id                = aws_cloudfront_distribution.this[0].hosted_zone_id
    evaluate_target_health = false
  }

  lifecycle {
    precondition {
      condition     = var.route53_zone_id != null && var.route53_record_name != null
      error_message = "route53_zone_id and route53_record_name are required when create_route53_alias_record is true."
    }
  }
}
