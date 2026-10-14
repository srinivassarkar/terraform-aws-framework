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
  description = "CIDR block for the staging VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "availability_zones" {
  description = "Target availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.10.10.0/24", "10.10.20.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for staging"
  type        = string
  default     = "t3.micro"
}
