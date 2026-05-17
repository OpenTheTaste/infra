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
      ManagedBy = "terraform"
      Component = "security_groups"
    },
    var.tags
  )
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.name_prefix}-alb-sg-"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.alb_http_ingress_cidrs
    description = "HTTP ingress"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.alb_https_ingress_cidrs
    description = "HTTPS ingress"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-alb-sg" })
}

resource "aws_security_group" "user" {
  name_prefix = "${var.name_prefix}-user-sg-"
  description = "User service security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.user_port
    to_port         = var.user_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "User service from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-user-sg" })
}

resource "aws_security_group" "admin" {
  name_prefix = "${var.name_prefix}-admin-sg-"
  description = "Admin service security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.admin_port
    to_port         = var.admin_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Admin service from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-admin-sg" })
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.name_prefix}-rds-sg-"
  description = "RDS security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.user.id]
    description     = "DB access from user service"
  }

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.admin.id]
    description     = "DB access from admin service"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-rds-sg" })
}

resource "aws_security_group" "rabbitmq" {
  name_prefix = "${var.name_prefix}-rabbitmq-sg-"
  description = "RabbitMQ security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.rabbitmq_amqp_port
    to_port         = var.rabbitmq_amqp_port
    protocol        = "tcp"
    security_groups = [aws_security_group.user.id]
    description     = "AMQP from user service"
  }

  ingress {
    from_port       = var.rabbitmq_amqp_port
    to_port         = var.rabbitmq_amqp_port
    protocol        = "tcp"
    security_groups = [aws_security_group.admin.id]
    description     = "AMQP from admin service"
  }

  ingress {
    from_port       = var.rabbitmq_management_port
    to_port         = var.rabbitmq_management_port
    protocol        = "tcp"
    security_groups = [aws_security_group.admin.id]
    description     = "Management UI from admin service"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-rabbitmq-sg" })
}

resource "aws_security_group" "lambda" {
  name_prefix = "${var.name_prefix}-lambda-sg-"
  description = "Lambda worker security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-lambda-sg" })
}

resource "aws_security_group" "monitoring" {
  name_prefix = "${var.name_prefix}-monitoring-sg-"
  description = "Monitoring server security group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.monitoring_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.admin.id]
      description     = "Monitoring access from admin service"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.name_prefix}-monitoring-sg" })
}

resource "aws_security_group_rule" "monitoring_grafana_from_alb" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring.id
  source_security_group_id = aws_security_group.alb.id
  description              = "Grafana access from ALB"
}

resource "aws_security_group_rule" "rds_from_lambda" {
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.lambda.id
  description              = "DB access from lambda worker"
}

resource "aws_security_group_rule" "rabbitmq_amqp_from_lambda" {
  type                     = "ingress"
  from_port                = var.rabbitmq_amqp_port
  to_port                  = var.rabbitmq_amqp_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rabbitmq.id
  source_security_group_id = aws_security_group.lambda.id
  description              = "AMQP from lambda worker"
}

resource "aws_security_group_rule" "rabbitmq_management_from_lambda" {
  type                     = "ingress"
  from_port                = var.rabbitmq_management_port
  to_port                  = var.rabbitmq_management_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rabbitmq.id
  source_security_group_id = aws_security_group.lambda.id
  description              = "Management API from lambda worker"
}
