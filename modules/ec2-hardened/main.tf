# Query latest official Ubuntu 24.04 LTS AMI if ami_id is not explicitly specified
data "aws_ami" "ubuntu" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  selected_ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.ubuntu[0].id
}

resource "aws_instance" "this" {
  for_each = var.instances

  ami                  = local.selected_ami_id
  instance_type        = each.value.instance_type
  subnet_id            = each.value.subnet_id
  iam_instance_profile = var.iam_instance_profile_name

  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = lookup(each.value, "associate_public_ip", false)
  monitoring                  = var.enable_detailed_monitoring
  user_data                   = lookup(each.value, "user_data", null)

  # CIS AWS Benchmark: Enforce IMDSv2 to protect against SSRF token harvesting
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # CIS AWS Benchmark: Enforce encrypted root EBS volume
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true

    tags = merge(
      var.tags,
      {
        Name        = "${each.key}-root-volume"
        Environment = var.environment
        ManagedBy   = "Terraform"
      }
    )
  }

  tags = merge(
    var.tags,
    lookup(each.value, "tags", {}),
    {
      Name        = each.key
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  lifecycle {
    ignore_changes = [ami]
  }
}
