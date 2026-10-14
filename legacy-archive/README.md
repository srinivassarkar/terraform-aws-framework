# Legacy Archive: Progressive Learning Labs (Days 1 to 9)

This directory preserves the historical development and progressive hands-on exercises completed during the initial Terraform study and experimentation phase.

All commits, implementations, and exercises from Day 1 through Day 9 remain intact in this archive to document the learning progression from basic HCL syntax to modular AWS infrastructure.

---

## Directory Index

| Directory | Topic / Focus | Core Concepts Covered |
| :--- | :--- | :--- |
| `DAY-1` | Locals, Variables, and Files | `local_file`, `variable` blocks, `terraform.tfvars`, basic EC2 provisioning |
| `DAY-2` | Data Sources & Remote State Basics | Querying existing VPC via `data "aws_vpc"`, S3 bucket provisioning |
| `DAY-3` | Provider Configurations | Multi-provider setups, aliases, regional endpoints |
| `DAY-4` | State Manipulation & Lifecycle | Terraform state CLI, output definitions, dependency graphs |
| `DAY-5` | VPC Modularization Prototype | Initial extraction of VPC resources into reusable child modules |
| `DAY-6` | EC2 and Security Group Modules | Decoupled compute instances and security group dynamic blocks |
| `DAY-7` | Application Load Balancer Module | ALB listener rules, target groups, and instance target attachments |
| `DAY-8` | Full Infrastructure Integration | Complete integration: Multi-AZ VPC, IGW, route tables, Nginx EC2 instances, and ALB |
| `DAY-9` | Advanced Orchestration Scaffold | Advanced module composition structure |

---

## Quick Revision Notes

For a rapid syntax and concept refresher covering core Terraform mechanics, lifecycle commands, interpolation, and state manipulation, consult [`quick-revision-notes.md`](quick-revision-notes.md).

---

## Production Successor

The production-grade, enterprise-ready evolution of these modules is maintained under `/modules`, orchestrated via `/environments`, secured with `/bootstrap` (S3 remote state + DynamoDB state locking), and tested locally via `/local/ministack`.
