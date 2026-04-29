# app stack

`stacks/app` is organized by dependency layers:

- `network.tf`: foundational network resources (`ami`, `vpc`, `security_groups`)
- `platform.tf`: shared platform resources (S3, ECS cluster/service, RDS, secrets, IAM)
- `app.tf`: workload resources (admin/user EC2, RabbitMQ, monitoring, Lambda, EventBridge)
- `edge.tf`: internet-facing edge resources (Route53, ACM, ALB, CloudFront)
- `main.tf`: shared providers/data/locals only

This keeps behavior unchanged while making dependency direction easier to review.
