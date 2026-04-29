# acm module

Creates ACM certificate and validates it via Route53 DNS records.

## Example

```hcl
module "acm" {
  source = "../../modules/acm"

  domain_name               = "example.cloud"
  subject_alternative_names = ["admin.example.cloud"]
  zone_id                   = module.route53.zone_id
}
```
