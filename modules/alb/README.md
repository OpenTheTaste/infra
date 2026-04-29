# alb module

Reusable ALB module with:
- ALB + ALB security group
- HTTP listener
- Optional HTTPS listener + HTTP redirect
- Multiple target groups

## Example

```hcl
module "alb" {
  source = "../../modules/alb"

  name       = "oplust-dev-alb"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  enable_https = false

  target_groups = {
    admin = {
      port     = 8080
      protocol = "HTTP"
      health_check = {
        path = "/health"
      }
    }
    user = {
      port     = 8081
      protocol = "HTTP"
    }
  }

  default_target_group = "admin"

  tags = {
    Project = "oplust"
    Env     = "dev"
  }
}
```
