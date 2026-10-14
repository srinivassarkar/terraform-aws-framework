terraform {
  # Modern Terraform 1.10+ native S3 remote backend with conditional write state locking (use_lockfile = true).
  # DynamoDB is no longer required.
  backend "s3" {
    bucket       = "framework-production-tfstate"
    key          = "production/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
