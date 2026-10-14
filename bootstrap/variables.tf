variable "aws_region" {
  description = "AWS region for provisioning the state backend resources"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Globally unique name for the S3 bucket hosting Terraform state"
  type        = string
}
