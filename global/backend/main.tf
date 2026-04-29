terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  resolved_bucket_name = coalesce(
    var.state_bucket_name,
    "${var.state_bucket_name_prefix}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
  )

  common_tags = merge(
    {
      Project   = var.project
      Env       = var.environment
      ManagedBy = "terraform"
      Component = "backend"
    },
    var.tags
  )
}

resource "aws_s3_bucket" "state" {
  bucket        = local.resolved_bucket_name
  force_destroy = var.force_destroy_bucket

  tags = merge(local.common_tags, { Name = local.resolved_bucket_name })
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

