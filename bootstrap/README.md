# Modern S3 Remote State Backend (Native Locking)

This directory provisions the AWS infrastructure required to securely store Terraform statefiles with native concurrency locking purely within Amazon S3, eliminating the legacy requirement of maintaining a secondary DynamoDB table.

---

## Architectural Evolution: Eliminating DynamoDB

Historically, Terraform relied on an external Amazon DynamoDB table (`LockID` partition key) to prevent concurrent state modifications.

Starting with **Terraform 1.10+**, Amazon S3's native support for conditional writes (`PutObject` with `If-None-Match: *`) allows Terraform to manage distributed locks directly within the S3 bucket via the `use_lockfile = true` parameter.

### Advantages of Native S3 Locking:

1. Zero Secondary Infrastructure: No DynamoDB table to provision, size, monitor, or manage.
2. Least Privilege IAM: IAM policies only need permissions on the target S3 bucket; no DynamoDB actions (`GetItem`, `PutItem`, `DeleteItem`) are required.
3. Cost Reduction: Eliminates DynamoDB read/write request costs and CloudWatch alarms.
4. Atomic Guarantee: S3 conditional writes guarantee that if two engineers or CI pipelines run `terraform apply` simultaneously, exactly one writer succeeds and the other receives an immediate conflict rejection (`412 Precondition Failed`).

---

## Resources Provisioned

1. AWS S3 Bucket:
   - Object Versioning Enabled: Allows rolling back corrupted or accidentally modified statefiles.
   - Server-Side Encryption (AES256): Statefiles are encrypted at rest.
   - Public Access Block: Complete block of public ACLs, policies, and bucket-level endpoints.
   - Bucket Policy Enforcing TLS 1.2+: Explicitly denies any unencrypted HTTP requests (`aws:SecureTransport = false`).
   - `prevent_destroy = true`: Safeguards the bucket against accidental `terraform destroy`.

---

## Usage in Environments

In root environment modules (e.g., `environments/production/backend.tf`), configure:

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
