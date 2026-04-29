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
  common_tags = merge(
    {
      Name      = var.name
      ManagedBy = "terraform"
      Component = "alb"
    },
    var.tags
  )

  listener_rules_by_priority = {
    for r in var.listener_rules : tostring(r.priority) => r
  }

  effective_alb_security_group_ids = length(var.alb_security_group_ids) > 0 ? var.alb_security_group_ids : [aws_security_group.alb[0].id]
}

resource "aws_security_group" "alb" {
  count = length(var.alb_security_group_ids) == 0 ? 1 : 0

  name_prefix = "${var.name}-alb-sg-"
  description = "Security group for ALB ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.http_ingress_cidrs
    description = "HTTP ingress"
  }

  dynamic "ingress" {
    for_each = var.enable_https ? [1] : []
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.https_ingress_cidrs
      description = "HTTPS ingress"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_lb" "this" {
  name                       = var.name
  internal                   = var.internal
  load_balancer_type         = "application"
  security_groups            = local.effective_alb_security_group_ids
  subnets                    = var.subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout               = var.idle_timeout

  tags = local.common_tags
}

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name        = substr("${var.name}-${each.key}", 0, 32)
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = try(each.value.target_type, "instance")

  health_check {
    enabled             = true
    path                = try(each.value.health_check.path, "/")
    matcher             = try(each.value.health_check.matcher, "200")
    interval            = try(each.value.health_check.interval, 30)
    timeout             = try(each.value.health_check.timeout, 5)
    healthy_threshold   = try(each.value.health_check.healthy_threshold, 2)
    unhealthy_threshold = try(each.value.health_check.unhealthy_threshold, 2)
  }

  tags = merge(local.common_tags, { TargetGroup = each.key })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.enable_https && var.redirect_http_to_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.enable_https && var.redirect_http_to_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.this[var.default_target_group].arn
    }
  }
}

resource "aws_lb_listener" "https" {
  count = var.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[var.default_target_group].arn
  }
}

resource "aws_lb_listener_rule" "http" {
  for_each = local.listener_rules_by_priority

  listener_arn = aws_lb_listener.http.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  }

  dynamic "condition" {
    for_each = length(try(each.value.host_headers, [])) > 0 ? [1] : []
    content {
      host_header {
        values = try(each.value.host_headers, [])
      }
    }
  }

  dynamic "condition" {
    for_each = length(try(each.value.path_patterns, [])) > 0 ? [1] : []
    content {
      path_pattern {
        values = try(each.value.path_patterns, [])
      }
    }
  }
}

resource "aws_lb_listener_rule" "https" {
  for_each = var.enable_https ? local.listener_rules_by_priority : {}

  listener_arn = aws_lb_listener.https[0].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  }

  dynamic "condition" {
    for_each = length(try(each.value.host_headers, [])) > 0 ? [1] : []
    content {
      host_header {
        values = try(each.value.host_headers, [])
      }
    }
  }

  dynamic "condition" {
    for_each = length(try(each.value.path_patterns, [])) > 0 ? [1] : []
    content {
      path_pattern {
        values = try(each.value.path_patterns, [])
      }
    }
  }
}
