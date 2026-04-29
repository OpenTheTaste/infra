module "app_stack" {
  source = "../../stacks/app"

  environment = var.environment
  project     = var.project
  aws_region  = var.aws_region
}
