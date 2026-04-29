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
  cluster_name = "${var.name_prefix}-transcoder-cluster"
  service_name = "${var.name_prefix}-transcoder"
  family_name  = coalesce(var.task_definition_family, "${var.name_prefix}-transcoder-task")

  common_tags = merge(
    {
      ManagedBy = "terraform"
      Component = "ecs_transcoder"
    },
    var.tags
  )

  container_environment = [
    for k, v in var.container_environment : {
      name  = k
      value = v
    }
  ]

  service_sg_id = var.service_security_group_id == null ? aws_security_group.service[0].id : var.service_security_group_id
}

data "aws_iam_policy_document" "assume_task" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${local.family_name}"
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}

resource "aws_ecs_cluster" "this" {
  name = local.cluster_name
  tags = merge(local.common_tags, { Name = local.cluster_name })
}

resource "aws_security_group" "service" {
  count = var.service_security_group_id == null ? 1 : 0

  name_prefix = "${local.service_name}-sg-"
  description = "Security group for ECS transcoder service"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.service_name}-sg" })
}

resource "aws_iam_role" "execution" {
  name               = "${local.family_name}-exec"
  assume_role_policy = data.aws_iam_policy_document.assume_task.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "execution_default" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name               = "${local.family_name}-task"
  assume_role_policy = data.aws_iam_policy_document.assume_task.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "task_s3" {
  count = length(var.s3_bucket_arns) > 0 ? 1 : 0

  statement {
    sid = "S3MediaAccess"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = concat(
      var.s3_bucket_arns,
      [for arn in var.s3_bucket_arns : "${arn}/*"]
    )
  }
}

resource "aws_iam_role_policy" "task_s3" {
  count = length(var.s3_bucket_arns) > 0 ? 1 : 0

  name   = "${local.family_name}-s3"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_s3[0].json
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.family_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.task_cpu)
  memory                   = tostring(var.task_memory)
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name        = var.container_name
      image       = var.container_image
      essential   = true
      environment = local.container_environment
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = merge(local.common_tags, { Name = local.family_name })

  depends_on = [aws_iam_role_policy_attachment.execution_default]
}

resource "aws_ecs_service" "this" {
  name            = local.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [local.service_sg_id]
    assign_public_ip = false
  }

  enable_execute_command = var.enable_execute_command

  tags = merge(local.common_tags, { Name = local.service_name })

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}
