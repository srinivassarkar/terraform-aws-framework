variable "project" {
  description = "Project name identifier"
  type        = string
  default     = "core"
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "cidr_block" {
  description = "Base IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid IPv4 CIDR notation."
  }
}

variable "availability_zones" {
  description = "List of availability zones for subnet distribution"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (must match availability_zones count)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (must match availability_zones count)"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to deploy NAT Gateways for private subnet egress"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Deploy a single NAT Gateway across AZs to minimize operational cost (staging/dev)"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames within the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS resolution support within the VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Custom tags to merge with default tags"
  type        = map(string)
  default     = {}
}
