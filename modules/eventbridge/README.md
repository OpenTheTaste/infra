# eventbridge module

Simple EventBridge scheduler module (default bus only):
- 1 scheduled rule
- 1 Lambda target
- Lambda invoke permission

## Example

```hcl
module "eventbridge" {
  source = "../../modules/eventbridge"

  name_prefix          = "oplust-dev"
  enabled              = true
  schedule_expression  = "rate(1 minute)"
  lambda_target_arn    = module.lambda_worker.function_arn
  lambda_function_name = module.lambda_worker.function_name

  tags = {
    Project = "oplust"
    Env     = "dev"
  }
}
```
