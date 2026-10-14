variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "ami_id" {
  description = "Explicit AMI ID. If null, automatically resolves the latest official Ubuntu 24.04 LTS AMI"
  type        = string
  default     = null
}

variable "instances" {
  description = "Map of instance configurations keyed by instance logical name"
  type = map(object({
    instance_type       = string
    subnet_id           = string
    associate_public_ip = optional(bool, false)
    user_data           = optional(string, null)
    tags                = optional(map(string), {})
  }))
}

variable "security_group_ids" {
  description = "List of security group IDs to assign to all instances in this set"
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name to attach to instances"
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GiB"
  type        = number
  default     = 20
}

variable "enable_detailed_monitoring" {
  description = "Enable 1-minute detailed CloudWatch monitoring"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Custom resource tags"
  type        = map(string)
  default     = {}
}
