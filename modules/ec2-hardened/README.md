# Hardened EC2 Compute Module

This module provisions AWS EC2 instances pre-configured against the CIS AWS Foundations Benchmark.

---

## Security Hardening Controls

1. IMDSv2 Mandatory Enforcement:
   - `http_tokens = "required"` blocks Server-Side Request Forgery (SSRF) metadata exfiltration attacks.
   - `http_put_response_hop_limit = 1` prevents network containers from communicating with host metadata service.
2. Root Volume Encryption:
   - Root EBS volumes are encrypted using AWS KMS/AES256 keys.
   - High-performance `gp3` storage volume type.
3. Decoupled AMI Resolution:
   - Uses `data.aws_ami` dynamic lookup for official Canonical Ubuntu 24.04 LTS images if no static AMI is provided.
   - Leverages `lifecycle { ignore_changes = [ami] }` to prevent unexpected instance recreation during minor OS patch updates.
4. Non-Destructive Scaling:
   - Keyed via `for_each` map instead of `count` index arrays, preventing index shift re-creations.

---

## Usage Example

```hcl
module "compute" {
  source = "../../modules/ec2-hardened"

  environment               = "staging"
  iam_instance_profile_name = module.app_iam.instance_profile_name
  security_group_ids        = [module.app_sg.security_group_id]

  instances = {
    "web-01" = {
      instance_type       = "t3.micro"
      subnet_id           = module.vpc.private_subnet_ids[0]
      associate_public_ip = false
      user_data           = file("${path.module}/scripts/bootstrap.sh")
    }
    "web-02" = {
      instance_type       = "t3.micro"
      subnet_id           = module.vpc.private_subnet_ids[1]
      associate_public_ip = false
      user_data           = file("${path.module}/scripts/bootstrap.sh")
    }
  }
}
```
