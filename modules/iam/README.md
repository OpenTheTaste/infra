# iam module

Creates IAM role, optional instance profile, managed policy attachments, and optional inline policy.

## Example

```hcl
module "ec2_iam" {
  source = "../../modules/iam"

  role_name = "oplust-dev-ec2-app"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  secret_arns        = ["*"]
  ssm_parameter_arns = ["*"]

  tags = {
    Project = "oplust"
    Env     = "dev"
  }
}
```
