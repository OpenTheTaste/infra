# rds module

Reusable RDS module with:
- DB subnet group
- DB security group
- Single RDS instance

## Example

```hcl
module "rds" {
  source = "../../modules/rds"

  identifier = "oplust-dev-db"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  engine         = "postgres"
  engine_version = "16.3"
  instance_class = "db.t4g.micro"
  db_name        = "oplust"

  username = "app_admin"
  password = var.db_password

  port = 5432
  allowed_security_group_ids = [
    module.user_ec2.security_group_id,
    module.admin_ec2.security_group_id
  ]

  tags = {
    Project = "oplust"
    Env     = "dev"
  }
}
```
