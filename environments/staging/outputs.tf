output "vpc_id" {
  description = "Staging VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "Staging Application Load Balancer public DNS URL"
  value       = "http://${module.alb.alb_dns_name}"
}

output "instance_private_ips" {
  description = "Private IP addresses of backend staging instances"
  value       = module.compute.private_ips
}

output "iam_role_arn" {
  description = "IAM Role ARN assumed by backend instances"
  value       = module.iam.role_arn
}
