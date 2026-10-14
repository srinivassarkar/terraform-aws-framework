# ---------------------------------------------------------------------------------------------------------------------
# 1. NETWORK TOPOLOGY
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  project              = var.project
  environment          = "staging"
  cidr_block           = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = true
  single_nat_gateway   = true # Staging cost optimization

  tags = {
    CostCenter = "Engineering-Staging"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# 2. SECURITY GROUPS (LEAST PRIVILEGE)
# ---------------------------------------------------------------------------------------------------------------------

# Edge Security Group for the Public ALB
module "alb_sg" {
  source = "../../modules/security-group"

  name        = "${var.project}-staging-alb-sg"
  description = "Public ALB ingress on port 80"
  vpc_id      = module.vpc.vpc_id
  environment = "staging"

  ingress_rules = [
    {
      description = "Allow inbound HTTP from internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    }
  ]

  egress_rules = [
    {
      description = "Allow egress to target instances"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]
}

# Backend Security Group: Restricted strictly to ALB security group
module "app_sg" {
  source = "../../modules/security-group"

  name        = "${var.project}-staging-app-sg"
  description = "App instances ingress strictly from ALB"
  vpc_id      = module.vpc.vpc_id
  environment = "staging"

  ingress_rules = [
    {
      description              = "Allow HTTP strictly from ALB security group"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]

  egress_rules = [
    {
      description = "Allow outbound HTTPS for OS patching via NAT Gateway"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      description = "Allow outbound HTTP for OS package updates via NAT Gateway"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    }
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# 3. IAM LEAST PRIVILEGE ROLE & INSTANCE PROFILE
# ---------------------------------------------------------------------------------------------------------------------

module "iam" {
  source = "../../modules/iam-least-privilege"

  role_name         = "${var.project}-staging-app-role"
  environment       = "staging"
  enable_ssm_access = true # Keyless terminal access via AWS SSM Session Manager
}

# ---------------------------------------------------------------------------------------------------------------------
# 4. HARDENED COMPUTE (PRIVATE SUBNETS)
# ---------------------------------------------------------------------------------------------------------------------

module "compute" {
  source = "../../modules/ec2-hardened"

  environment               = "staging"
  iam_instance_profile_name = module.iam.instance_profile_name
  security_group_ids        = [module.app_sg.security_group_id]
  root_volume_size          = 20

  instances = {
    "staging-app-01" = {
      instance_type       = var.instance_type
      subnet_id           = module.vpc.private_subnet_ids[0]
      associate_public_ip = false
      user_data           = <<-EOF
        #!/bin/bash
        set -xe
        apt-get update -y
        apt-get install -y nginx
        systemctl enable nginx
        systemctl start nginx
        echo "<h1>Staging Node: $(hostname) - AZ: ${var.availability_zones[0]}</h1>" > /var/www/html/index.html
      EOF
    }
    "staging-app-02" = {
      instance_type       = var.instance_type
      subnet_id           = module.vpc.private_subnet_ids[1]
      associate_public_ip = false
      user_data           = <<-EOF
        #!/bin/bash
        set -xe
        apt-get update -y
        apt-get install -y nginx
        systemctl enable nginx
        systemctl start nginx
        echo "<h1>Staging Node: $(hostname) - AZ: ${var.availability_zones[1]}</h1>" > /var/www/html/index.html
      EOF
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# 5. APPLICATION LOAD BALANCER (PUBLIC SUBNETS)
# ---------------------------------------------------------------------------------------------------------------------

module "alb" {
  source = "../../modules/alb"

  name                = "${var.project}-staging-alb"
  environment         = "staging"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.public_subnet_ids
  security_group_ids  = [module.alb_sg.security_group_id]
  target_port         = 80
  health_check_path   = "/"
  target_instance_ids = module.compute.instance_ids
}
