# Local test harness verifying modules against local MiniStack instance without AWS billing

module "vpc" {
  source = "../../modules/vpc"

  project              = var.project
  environment          = "dev"
  cidr_block           = "10.99.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.99.1.0/24", "10.99.2.0/24"]
  private_subnet_cidrs = ["10.99.10.0/24", "10.99.20.0/24"]
  enable_nat_gateway   = false # Disabled for lightweight local emulation
  single_nat_gateway   = true
}

module "test_sg" {
  source = "../../modules/security-group"

  name        = "${var.project}-local-sg"
  description = "Security group for local validation"
  vpc_id      = module.vpc.vpc_id
  environment = "dev"

  ingress_rules = [
    {
      description = "Allow local HTTP traffic"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    }
  ]
}
