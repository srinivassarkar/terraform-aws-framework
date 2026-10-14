aws_region           = "us-east-1"
project              = "framework"
vpc_cidr             = "10.20.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
private_subnet_cidrs = ["10.20.10.0/24", "10.20.20.0/24", "10.20.30.0/24"]
instance_type        = "t3.medium"
