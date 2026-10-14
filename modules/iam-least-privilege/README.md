# Least-Privilege IAM Module

This module provisions an IAM Role, Trust Policy, Permissions Policy, and Instance Profile adhering strictly to the principle of least privilege.

---

## Key Enterprise Security Capabilities

1. Zero Long-Lived Static Keys: Instances assume IAM roles natively via temporary STS credentials rotated automatically by AWS.
2. SSM Session Manager Integration: Attaches `AmazonSSMManagedInstanceCore` by default. This eliminates the necessity of inbound SSH port 22 access, bastion hosts, and static `.pem` key pairs.
3. Scoped Resource Boundaries: Rather than granting `s3:*` on `*`, policies are constructed using `data "aws_iam_policy_document"` scoping actions specifically to explicit bucket ARNs and paths.

---

## Usage Example

```hcl
module "app_iam" {
  source = "../../modules/iam-least-privilege"

  role_name         = "app-production-backend-role"
  environment       = "production"
  enable_ssm_access = true
  s3_bucket_arns    = [module.app_storage.bucket_arn]

  tags = {
    Compliance = "SOC2"
  }
}
```
