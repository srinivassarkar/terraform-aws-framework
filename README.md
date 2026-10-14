# Enterprise AWS Infrastructure-as-Code Framework

An enterprise-grade, modular AWS infrastructure framework provisioned with Terraform and OpenTofu. Designed around zero-trust network boundaries, CIS AWS Foundations Benchmark hardening, automated native S3 state locking, and multi-environment orchestration.

---

## Architectural Overview

The framework deploys a resilient, multi-tier cloud topology across multiple Availability Zones. Incoming internet traffic terminates at an Application Load Balancer in public subnets, which forwards requests exclusively to hardened compute instances situated in isolated private subnets. Outbound egress for package updates and API integrations is managed via dedicated NAT Gateways.

```mermaid
flowchart TD
    subgraph Internet ["Public Internet"]
        Client["External Clients"]
    end

    subgraph AWS ["AWS Cloud: Target VPC (10.0.0.0/16)"]
        IGW["Internet Gateway"]

        subgraph PublicSubnets ["Public Subnets (Multi-AZ)"]
            ALB["Application Load Balancer"]
            NAT["NAT Gateway (EIP Attached)"]
        end

        subgraph PrivateSubnets ["Private Subnets (Multi-AZ)"]
            App1["Hardened EC2: Node 1 (IMDSv2)"]
            App2["Hardened EC2: Node 2 (IMDSv2)"]
        end

        subgraph IAMSec ["Identity & Access Management"]
            SSM["AWS Systems Manager (Session Manager)"]
            IAMRole["Least-Privilege Instance Profile"]
        end

        subgraph StateManagement ["Modern S3 State Backend (Terraform 1.10+)"]
            S3["S3 State Bucket (Versioning + TLS 1.2+ Enforced)"]
            S3Lock["Native S3 State Locking (use_lockfile = true via If-None-Match)"]
        end
    end

    Client -->|HTTPS / Port 443| ALB
    ALB -->|HTTP / Port 80 (SG Ref)| App1
    ALB -->|HTTP / Port 80 (SG Ref)| App2
    IGW --> PublicSubnets
    App1 -->|Egress via NAT| NAT
    App2 -->|Egress via NAT| NAT
    NAT --> IGW
    SSM -.->|Keyless Terminal Access| IAMRole
    IAMRole -.-> App1
    IAMRole -.-> App2
    S3 --- S3Lock
```

---

## Key Enterprise Engineering Highlights

- Zero Static Credentials: SSH port 22 is closed across all security groups. Instance administrative access is provided exclusively via AWS Systems Manager (SSM) Session Manager using short-lived IAM credentials.
- CIS Benchmark Hardening: Instances enforce mandatory IMDSv2 (`http_tokens = "required"`, hop limit 1) to eliminate SSRF-based metadata and credential theft. All EBS root volumes are encrypted at rest with `gp3`.
- Decoupled Security Group Rules: Avoids inline `ingress` and `egress` blocks to prevent state drift, rule flapping, and cyclical dependency errors when cross-referencing security groups.
- Deterministic Resource Addressing: All subnets, route tables, and compute nodes are indexed via `for_each` maps rather than `count` arrays, preventing index shift re-creations during resource updates.
- Native S3 Concurrency Control: Leverages modern Terraform 1.10+ native S3 state locking (`use_lockfile = true`) powered by S3 conditional writes (`If-None-Match: *`). Eliminates the complexity, cost, and IAM overhead of external DynamoDB tables.
- Zero-Cost Local Emulation: Fully compatible with [MiniStack](https://ministack.org/) and LocalStack for offline integration testing without incurring AWS billing.

---

## Repository Structure

```
├── .github/
│   └── workflows/
│       └── terraform-ci.yml           # Automated linting (fmt, tflint) and Trivy security scanner
├── bootstrap/                         # Remote state storage (S3) and native locking provisioning
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── modules/                           # Reusable, versioned infrastructure modules
│   ├── vpc/                           # Multi-AZ VPC, subnets, IGW, NAT Gateway, route tables
│   ├── security-group/                # Decoupled AWS Provider v5+ security group rules
│   ├── ec2-hardened/                  # CIS-hardened compute with IMDSv2 & encrypted EBS
│   ├── iam-least-privilege/           # Scoped IAM roles, SSM policies, and instance profiles
│   └── alb/                           # Application Load Balancer with health checks & listeners
├── environments/                      # Root configuration layers per environment
│   ├── staging/                       # Cost-optimized single-NAT setup for staging validation
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   └── versions.tf
│   └── production/                    # High-availability 3-AZ multi-NAT setup with native S3 locking
│       ├── backend.tf
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── terraform.tfvars
│       └── versions.tf
├── local/                             # Local emulation harness for offline development
│   └── ministack/                     # MiniStack endpoint overrides for zero-cost testing
├── legacy-archive/                    # Preserved historical learning labs (Day 1 through Day 9)
│   ├── README.md
│   ├── quick-revision-notes.md        # 1,900-line comprehensive HCL syntax and revision guide
│   └── DAY-1 ... DAY-9
├── .gitignore
├── .tflint.hcl
└── README.md
```

---

## Module Catalog

### 1. Networking (`modules/vpc`)
Provisions a dual-tier VPC across multiple Availability Zones.
- Configurable `single_nat_gateway` toggle: Set to `true` in non-production environments to avoid idle multi-AZ NAT Gateway charges; set to `false` in production for full AZ failure isolation.
- Automatic route table propagation and subnet association.
- Parameterized CIDR validation via native Terraform type constraints.

### 2. Security Boundaries (`modules/security-group`)
Implements independent `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule` resources.
- Permits direct referencing between security groups (e.g., App SG permits ingress only from ALB SG) without cyclical reference errors.
- Strict egress scoping replacing wide-open egress where applicable.

### 3. Compute (`modules/ec2-hardened`)
Deploys Linux compute instances adhering to CIS AWS Foundations Benchmark:
- IMDSv2 enforced (`http_tokens = "required"`, `http_put_response_hop_limit = 1`).
- Root volume encryption enforced with `volume_type = "gp3"`.
- Dynamic official Ubuntu 24.04 LTS AMI lookup with `lifecycle { ignore_changes = [ami] }` to avoid unwanted teardowns during upstream patch releases.

### 4. Identity & Access Management (`modules/iam-least-privilege`)
Provisions IAM Roles and Instance Profiles adhering to least-privilege standards:
- Explicit trust relationship (`sts:AssumeRole`) for `ec2.amazonaws.com`.
- Attaches `AmazonSSMManagedInstanceCore` to enable terminal sessions via AWS Systems Manager without inbound network ports.
- Scoped S3 object read/write policies constructed using `data "aws_iam_policy_document"`.

### 5. Ingress Controller (`modules/alb`)
Provisions an Application Load Balancer spanning public subnets:
- Configurable health checks (`interval`, `timeout`, `healthy_threshold`, `matcher`).
- Dynamic target registration using `for_each` mapping.
- Native listener routing for port 80 HTTP and TLS termination readiness.

---

## Remote State Management & Modern S3 Native Locking

Historically, Terraform required an external DynamoDB table to achieve distributed state locking. With Terraform 1.10+, Amazon S3 natively supports conditional writes (`PutObject` with `If-None-Match`), allowing locks to be created and released directly inside the S3 state bucket.

```
Developer A: terraform apply                     Developer B: terraform apply
             |                                                |
             v                                                v
 S3 Conditional PutObject (.tflock)               S3 Conditional PutObject (.tflock)
             |                                                |
    [ Lock Granted: 200 OK ]                     [ Lock Conflict: 412 Precondition Failed ]
             |                                                |
 Modifies Infrastructure                           Execution Safely Aborted
             |
 Writes State to S3 (Versioned)
             |
 Deletes .tflock file
```

### Initial State Bootstrap Sequence

When initializing a new AWS account, execute the bootstrap module locally:

```bash
cd bootstrap
terraform init
terraform apply -var="state_bucket_name=company-tfstate-production"
```

Once provisioned, configure the backend block in `environments/production/backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket       = "company-tfstate-production"
    key          = "production/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
```

---

## Brownfield Infrastructure Migration Playbook

A frequent real-world challenge in enterprise environments is bringing existing, manually provisioned AWS infrastructure under Terraform management without downtime or resource destruction.

### Step-by-Step Migration Pattern

1. Discover and Inventory Unmanaged Resources:
   Identify resource IDs from the AWS Console or AWS CLI (e.g., VPC ID `vpc-0123456789abcdef0`, Subnet ID `subnet-0123456789abcdef0`).

2. Author Equivalent HCL Blocks:
   Write matching resource definitions matching the exact configuration of the live resources:
   ```hcl
   resource "aws_vpc" "imported" {
     cidr_block           = "10.0.0.0/16"
     enable_dns_hostnames = true
     enable_dns_support   = true
     tags = {
       Name = "stage-legacy-vpc"
     }
   }
   ```

3. Import Resources into the Statefile:
   Import the live resource ID directly into Terraform's state graph:
   ```bash
   terraform import aws_vpc.imported vpc-0123456789abcdef0
   terraform import aws_subnet.public subnet-0123456789abcdef0
   terraform import aws_route_table.public rtb-0123456789abcdef0
   ```
   *(Note: In Terraform 1.5+, declarative `import` blocks can be used instead of CLI commands).*

4. Reconcile Drift:
   Run `terraform plan`. Refine the HCL attributes until Terraform reports:
   ```
   No changes. Your infrastructure matches the configuration.
   ```

5. Modularize:
   Refactor the imported resources from monolithic files into reusable modules (`modules/vpc`, `modules/security-group`) using `moved` blocks to avoid resource destruction during refactoring:
   ```hcl
   moved {
     from = aws_vpc.imported
     to   = module.vpc.aws_vpc.this
   }
   ```

---

## Local Zero-Cost Testing with MiniStack

To test infrastructure code locally without provisioning real AWS resources or incurring cloud billing:

1. Launch the local emulator:
   ```bash
   docker run --rm -it -p 4566:4566 ministack/ministack:latest
   ```

2. Execute Terraform commands against the local harness:
   ```bash
   cd local/ministack
   terraform init
   terraform plan
   terraform apply -auto-approve
   ```

---

## Automated CI/CD Validation

Every commit and pull request triggers `.github/workflows/terraform-ci.yml`, which runs:

1. `terraform fmt -check -recursive`: Enforces standard HashiCorp formatting.
2. `tflint --recursive`: Detects AWS-specific anti-patterns and deprecated attributes.
3. `terraform validate`: Verifies configuration syntax and type constraints across modules and environment roots.
4. `trivy config .`: Scans for security misconfigurations and CIS benchmark deviations.

---

## Historical Learning Archive & Quick Revision Notes

- Historical Labs: The initial hands-on labs and progressive exercises (Day 1 through Day 9) covering basic syntax, data sources, provider aliasing, and prototype modules are preserved in [`legacy-archive/`](legacy-archive/README.md).
- Quick Revision Notes: Comprehensive revision notes covering core syntax, CLI commands, interpolation, lifecycle rules, and state management are available in [`legacy-archive/quick-revision-notes.md`](legacy-archive/quick-revision-notes.md).
