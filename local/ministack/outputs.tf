output "vpc_id" {
  description = "Mock VPC ID provisioned on MiniStack"
  value       = module.vpc.vpc_id
}

output "security_group_id" {
  description = "Mock Security Group ID provisioned on MiniStack"
  value       = module.test_sg.security_group_id
}
