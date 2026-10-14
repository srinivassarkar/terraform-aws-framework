variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name identifier"
  type        = string
  default     = "framework"
}

variable "vpc_cidr" {
  description = "CIDR block for the production VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "Target availability zones (minimum 3 for HA production)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.20.0/24", "10.20.30.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for production"
  type        = string
  default     = "t3.medium"
}
