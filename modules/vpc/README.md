# vpc module

Reusable VPC module with:
- VPC
- Internet Gateway
- Public subnets
- Private subnets
- NAT gateway(s)
- Route tables and associations

## Example

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name = "oplust-dev"
  vpc_cidr = "10.10.0.0/16"

  availability_zones  = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnet_cidrs = ["10.10.0.0/24", "10.10.1.0/24"]
  private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project = "oplust"
    Env     = "dev"
  }
}
```
