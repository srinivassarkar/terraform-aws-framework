# VPC Infrastructure Module

This module provisions an enterprise-grade, multi-Availability Zone AWS Virtual Private Cloud (VPC) featuring public and private subnets, Internet Gateway, Elastic IPs, NAT Gateways with cost-conscious single-NAT or high-availability multi-NAT toggles, and dedicated route tables.

---

## Architecture

```
                       Internet
                          |
                   [ Internet Gateway ]
                          |
             +------------+------------+
             |                         |
     [ Public Subnet A ]       [ Public Subnet B ]
      (EIP + NAT Gateway)       (ALB / Ingress)
             |                         |
     +-------+                         +-------+
     |                                         |
[ Private Subnet A ]                   [ Private Subnet B ]
 (App Instances / IMDSv2)               (App Instances / IMDSv2)
```

---

## Features

- Predictable Resource Addressing: Subnets, route tables, and NAT gateways are managed using `for_each` and keyed maps to prevent index shifting on deletion.
- Cost Optimization: Configurable `single_nat_gateway = true` for staging/dev to avoid unnecessary multi-AZ NAT gateway hourly charges.
- Subnet Segmentation: Dedicated public subnets for edge components (ALB) and isolated private subnets for compute workloads.
- Strict Tagging Policy: Enforces `Name`, `Environment`, and `ManagedBy = Terraform` metadata tags.

---

## Usage Example

```hcl
module "vpc" {
  source = "../../modules/vpc"

  project              = "ecommerce"
  environment          = "staging"
  cidr_block           = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    Owner = "PlatformTeam"
  }
}
```
