output "instances" {
  description = "Map of all provisioned EC2 instances with attributes"
  value = {
    for name, instance in aws_instance.this : name => {
      id                 = instance.id
      arn                = instance.arn
      private_ip         = instance.private_ip
      public_ip          = instance.public_ip
      subnet_id          = instance.subnet_id
      availability_zone  = instance.availability_zone
      primary_network_id = instance.primary_network_interface_id
    }
  }
}

output "instance_ids" {
  description = "List of all provisioned EC2 instance IDs"
  value       = [for instance in aws_instance.this : instance.id]
}

output "private_ips" {
  description = "List of private IP addresses of provisioned instances"
  value       = [for instance in aws_instance.this : instance.private_ip]
}
