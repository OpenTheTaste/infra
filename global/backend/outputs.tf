output "state_bucket_name" {
  description = "S3 bucket name for Terraform state."
  value       = aws_s3_bucket.state.bucket
}

output "state_bucket_arn" {
  description = "S3 bucket ARN for Terraform state."
  value       = aws_s3_bucket.state.arn
}

output "aws_region" {
  description = "AWS region where backend resources were created."
  value       = data.aws_region.current.region
}

output "backend_hcl_values" {
  description = "Values to copy into backend.hcl."
  value = {
    bucket       = aws_s3_bucket.state.bucket
    region       = data.aws_region.current.region
    use_lockfile = true
  }
}
