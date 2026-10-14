variable "name" {
  description = "Name identifier for the Security Group"
  type        = string
}

variable "description" {
  description = "Description for the Security Group purpose"
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "The target VPC ID where the Security Group resides"
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules with port range, protocol, and either CIDR or source security group ID"
  type = list(object({
    description              = optional(string, null)
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_block               = optional(string, null)
    source_security_group_id = optional(string, null)
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    description = optional(string, "Allow outbound traffic")
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = optional(string, null)
  }))
  default = [
    {
      description = "Allow all outbound traffic by default"
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    }
  ]
}

variable "tags" {
  description = "Custom resource tags"
  type        = map(string)
  default     = {}
}
