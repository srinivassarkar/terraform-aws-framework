# Application Load Balancer Module

This module provisions an AWS Application Load Balancer (ALB) complete with target groups, automated health checks, listener configurations, and dynamic target registration.

---

## Architectural Role

The ALB resides in public subnets spanning multiple Availability Zones. It acts as the single public entry point for incoming HTTP/HTTPS traffic, terminating incoming connections and routing requests to private backend instances.

```
Clients (Internet)
       |
  [ ALB: Port 80 ] (Public Subnets)
       |
       +------------+------------+
       |                         |
[ Web Instance 1 ]       [ Web Instance 2 ]
(Private Subnet A)       (Private Subnet B)
```

---

## Usage Example

```hcl
module "alb" {
  source = "../../modules/alb"

  name                = "app-staging-alb"
  environment         = "staging"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.public_subnet_ids
  security_group_ids  = [module.alb_sg.security_group_id]
  target_port         = 80
  health_check_path   = "/healthz"
  target_instance_ids = module.compute.instance_ids

  tags = {
    Tier = "Edge"
  }
}
```
