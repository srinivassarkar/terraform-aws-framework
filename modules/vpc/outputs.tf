output "vpc_id" {
  description = "The ID of the provisioned VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the provisioned VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_arn" {
  description = "The ARN of the provisioned VPC"
  value       = aws_vpc.this.arn
}

output "public_subnet_ids" {
  description = "List of IDs for all public subnets"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "List of IDs for all private subnets"
  value       = [for s in aws_subnet.private : s.id]
}

output "public_subnets_map" {
  description = "Map of public subnets keyed by availability zone"
  value = {
    for az, s in aws_subnet.public : az => {
      id         = s.id
      cidr_block = s.cidr_block
      arn        = s.arn
    }
  }
}

output "private_subnets_map" {
  description = "Map of private subnets keyed by availability zone"
  value = {
    for az, s in aws_subnet.private : az => {
      id         = s.id
      cidr_block = s.cidr_block
      arn        = s.arn
    }
  }
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "List of IDs for all NAT Gateways"
  value       = [for ngw in aws_nat_gateway.this : ngw.id]
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Map of private route table IDs keyed by availability zone"
  value       = { for az, rt in aws_route_table.private : az => rt.id }
}
