output "s3_bucket_id" {
  description = "The name/ID of the S3 state bucket"
  value       = aws_s3_bucket.state_bucket.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 state bucket"
  value       = aws_s3_bucket.state_bucket.arn
}

output "backend_config_snippet" {
  description = "Ready-to-use modern backend configuration snippet for environment root modules (Terraform 1.10+ native S3 locking)"
  value       = <<-EOT
    backend "s3" {
      bucket       = "${aws_s3_bucket.state_bucket.id}"
      key          = "<environment>/terraform.tfstate"
      region       = "${var.aws_region}"
      use_lockfile = true
      encrypt      = true
    }
  EOT
}
