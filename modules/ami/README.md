# ami module

Selects a latest AMI using filters, then exposes the AMI ID.

## Example

```hcl
module "ami_amzn2" {
  source = "../../modules/ami"

  owners        = ["amazon"]
  name_patterns = ["amzn2-ami-hvm-*-x86_64-gp2"]
}

module "admin_ec2" {
  source = "../../modules/ec2_service"

  name      = "admin"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]
  ami_id    = module.ami_amzn2.id
}
```
