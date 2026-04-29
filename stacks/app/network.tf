module "ami_linux" {
  source = "../../modules/ami"

  owners        = ["amazon"]
  name_patterns = ["al2023-ami-*-x86_64"]
}

module "vpc" {
  source = "../../modules/vpc"

  name     = "${var.project}-${var.environment}"
  vpc_cidr = "10.10.0.0/16"

  availability_zones   = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnet_cidrs  = ["10.10.0.0/24", "10.10.1.0/24"]
  private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.common_tags
}

module "security_groups" {
  source = "../../modules/security_groups"

  name_prefix = "${var.project}-${var.environment}"
  vpc_id      = module.vpc.vpc_id
  admin_port  = 8081
  user_port   = 8080
  db_port     = 3306

  tags = local.common_tags
}
