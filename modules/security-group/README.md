# Security Group Module

This module provisions an AWS Security Group using decoupled `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule` resources (AWS Provider v5+ standard).

---

## Architectural Rationale

Inline rules (`ingress {}` and `egress {}` inside `aws_security_group`) are notoriously prone to state drift, rule flapping, and cyclical dependency errors when cross-referencing other security groups (e.g., ALB security group to EC2 security group).

By separating security group container creation from rule definitions:
1. Cyclical dependencies between security groups are completely eliminated.
2. Individual rules can be updated, added, or removed without destroying the security group itself.
3. Both CIDR-based ingress and SG-referenced ingress are supported cleanly.

---

## Usage Example

```hcl
module "app_sg" {
  source = "../../modules/security-group"

  name        = "app-backend-sg"
  description = "Ingress restricted strictly to ALB security group"
  vpc_id      = module.vpc.vpc_id
  environment = "staging"

  ingress_rules = [
    {
      description              = "Allow HTTP from ALB only"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]

  egress_rules = [
    {
      description = "Allow HTTPS outbound for package updates"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    }
  ]
}
```
