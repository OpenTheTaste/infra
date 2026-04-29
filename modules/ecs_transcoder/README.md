# ecs_transcoder module

Creates a baseline ECS Fargate transcoder stack:
- ECS Cluster
- Task Definition + Service
- Execution/Task IAM roles
- CloudWatch log group
- Optional module-created service security group
- Optional S3 media bucket access policy on task role
