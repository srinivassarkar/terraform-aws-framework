# ---------------------------------------------------------------------------------------------------------------------
# 1. HIGH-AVAILABILITY NETWORK TOPOLOGY (3-AZ)
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  project              = var.project
  environment          = "prod"
  cidr_block           = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = true
  single_nat_gateway   = false # Multi-AZ High Availability (dedicated NAT Gateway per AZ)

  tags = {
    CostCenter = "Engineering-Production"
    SLA        = "99.99"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# 2. SECURITY GROUPS (STRICT ZERO-TRUST BOUNDARIES)
# ---------------------------------------------------------------------------------------------------------------------

# Public ingress security group for the Application Load Balancer
module "alb_sg" {
  source = "../../modules/security-group"

  name        = "${var.project}-prod-alb-sg"
  description = "Production ALB ingress on port 80"
  vpc_id      = module.vpc.vpc_id
  environment = "prod"

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
      description = "Allow egress to backend workloads"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]
}

# Backend security group: Traffic strictly permitted from ALB security group
module "app_sg" {
  source = "../../modules/security-group"

  name        = "${var.project}-prod-app-sg"
  description = "Production app nodes ingress strictly from ALB"
  vpc_id      = module.vpc.vpc_id
  environment = "prod"

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
      description = "Allow outbound HTTPS for API and OS patching via NAT Gateway"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      description = "Allow outbound HTTP for package repositories"
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

  role_name         = "${var.project}-prod-app-role"
  environment       = "prod"
  enable_ssm_access = true # Keyless terminal access via AWS SSM Session Manager
}

# ---------------------------------------------------------------------------------------------------------------------
# 4. HARDENED COMPUTE (ACROSS 3 PRIVATE AZs)
# ---------------------------------------------------------------------------------------------------------------------

module "compute" {
  source = "../../modules/ec2-hardened"

  environment                = "prod"
  iam_instance_profile_name  = module.iam.instance_profile_name
  security_group_ids         = [module.app_sg.security_group_id]
  root_volume_size           = 50
  enable_detailed_monitoring = true

  instances = {
    "prod-app-01" = {
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
        echo "<h1>Production Cluster: Node 1 [${var.availability_zones[0]}]</h1>" > /var/www/html/index.html
      EOF
    }
    "prod-app-02" = {
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
        echo "<h1>Production Cluster: Node 2 [${var.availability_zones[1]}]</h1>" > /var/www/html/index.html
      EOF
    }
    "prod-app-03" = {
      instance_type       = var.instance_type
      subnet_id           = module.vpc.private_subnet_ids[2]
      associate_public_ip = false
      user_data           = <<-EOF
        #!/bin/bash
        set -xe
        apt-get update -y
        apt-get install -y nginx
        systemctl enable nginx
        systemctl start nginx
        echo "<h1>Production Cluster: Node 3 [${var.availability_zones[2]}]</h1>" > /var/www/html/index.html
      EOF
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# 5. APPLICATION LOAD BALANCER (SPANNING 3 PUBLIC AZs)
# ---------------------------------------------------------------------------------------------------------------------

module "alb" {
  source = "../../modules/alb"

  name                       = "${var.project}-prod-alb"
  environment                = "prod"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.public_subnet_ids
  security_group_ids         = [module.alb_sg.security_group_id]
  target_port                = 80
  health_check_path          = "/"
  target_instance_ids        = module.compute.instance_ids
  enable_deletion_protection = true
}
