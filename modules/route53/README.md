# route53 module

Route53 module for:
- Optional hosted zone creation
- Apex A alias -> ALB
- Admin subdomain A alias -> ALB

## Example

```hcl
module "route53" {
  source = "../../modules/route53"

  domain_name      = "example.cloud"
  admin_subdomain  = "admin"
  alb_dns_name     = module.alb.alb_dns_name
  alb_zone_id      = module.alb.alb_zone_id
  create_hosted_zone = true 
  //false 일 경우 existing_zone_id = null 에러 
}
```
