variable "name" {
  description = "Name identifier for the Application Load Balancer"
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "internal" {
  description = "Whether the load balancer is internal or internet-facing"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "The target VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of public subnet IDs for ALB placement (minimum 2 across different AZs)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs assigned to the ALB"
  type        = list(string)
}

variable "target_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "Protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
}

variable "target_instance_ids" {
  description = "List of EC2 instance IDs to register with the target group"
  type        = list(string)
  default     = []
}

variable "health_check_path" {
  description = "Destination path for health check requests"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Approximate amount of time between health checks (seconds)"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Amount of time during which no response means a failed health check (seconds)"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of consecutive health checks successes required before considering an unhealthy target healthy"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering a target unhealthy"
  type        = number
  default     = 3
}

variable "health_check_matcher" {
  description = "HTTP response codes to use when checking for a healthy responses from a target"
  type        = string
  default     = "200-399"
}

variable "deregistration_delay" {
  description = "Time to wait before deregistering a target in seconds"
  type        = number
  default     = 60
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Custom resource tags"
  type        = map(string)
  default     = {}
}
