output "role_arn" {
  description = "ARN of the provisioned IAM role"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the provisioned IAM role"
  value       = aws_iam_role.this.name
}

output "instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.this.name
}

output "instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.this.arn
}
