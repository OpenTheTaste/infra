# ec2_service module

Reusable single-EC2 service module with:
- Security Group
- EC2 instance
- Optional ALB target group attachment

No Auto Scaling Group and no EIP by default.

## Example

```hcl
module "admin_ec2" {
  source = "../../modules/ec2_service"

  name      = "admin"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]
  ami_id    = data.aws_ami.amazon_linux.id

  instance_type = "t3.medium"

  ingress_rules = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "admin service"
    }
  ]

  target_group_attachments = [
    {
      target_group_arn = module.alb.admin_tg_arn
      port             = 8080
    }
  ]

  tags = {
    Project = "oplust"
    Env     = "dev"
  }
}
```
