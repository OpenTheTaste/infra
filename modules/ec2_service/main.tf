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
      Component = "ec2_service"
    },
    var.tags
  )

  primary_security_group_id = var.create_security_group ? aws_security_group.this[0].id : var.security_group_id
}

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.name}-sg-"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = try(ingress.value.description, null)
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
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

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile_name
  user_data                   = var.user_data
  associate_public_ip_address = var.associate_public_ip
  monitoring                  = var.enable_detailed_monitoring
  vpc_security_group_ids      = concat([local.primary_security_group_id], var.additional_security_group_ids)

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_volume_encrypted
    delete_on_termination = true
  }

  tags = local.common_tags
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for idx, item in var.target_group_attachments :
    tostring(idx) => item
  }

  target_group_arn = each.value.target_group_arn
  target_id        = aws_instance.this.id
  port             = try(each.value.port, null)
}
