variable "aws_region" {
  description = "AWS mock region"
  type        = string
  default     = "us-east-1"
}

variable "ministack_endpoint" {
  description = "Local endpoint URL for MiniStack / LocalStack"
  type        = string
  default     = "http://localhost:4566"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "ministack-test"
}
