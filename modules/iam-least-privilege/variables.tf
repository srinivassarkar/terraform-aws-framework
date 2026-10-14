variable "role_name" {
  description = "Name of the IAM role to create"
  type        = string
}

variable "service_principal" {
  description = "The AWS service principal authorized to assume this role"
  type        = string
  default     = "ec2.amazonaws.com"
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "enable_ssm_access" {
  description = "Attach AmazonSSMManagedInstanceCore to allow passwordless SSM Session Manager console access"
  type        = bool
  default     = true
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs to grant scoped read/write access to"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Custom resource tags"
  type        = map(string)
  default     = {}
}
