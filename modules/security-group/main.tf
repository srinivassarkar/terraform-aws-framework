resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name        = var.name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = {
    for idx, rule in var.ingress_rules :
    idx => rule
    if rule.cidr_block != null
  }

  security_group_id = aws_security_group.this.id
  description       = each.value.description
  ip_protocol       = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr_block

  tags = {
    Name = "${var.name}-ingress-${each.key}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "source_sg" {
  for_each = {
    for idx, rule in var.ingress_rules :
    idx => rule
    if rule.source_security_group_id != null
  }

  security_group_id            = aws_security_group.this.id
  description                  = each.value.description
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  referenced_security_group_id = each.value.source_security_group_id

  tags = {
    Name = "${var.name}-ingress-sg-${each.key}"
  }
}

resource "aws_vpc_security_group_egress_rule" "cidr" {
  for_each = {
    for idx, rule in var.egress_rules :
    idx => rule
    if rule.cidr_block != null
  }

  security_group_id = aws_security_group.this.id
  description       = each.value.description
  ip_protocol       = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr_block

  tags = {
    Name = "${var.name}-egress-${each.key}"
  }
}
