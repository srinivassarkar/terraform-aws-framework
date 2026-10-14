resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-vpc"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-igw"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_subnet" "public" {
  for_each = {
    for idx, az in var.availability_zones :
    az => {
      cidr_block = var.public_subnet_cidrs[idx]
      az         = az
    }
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-public-${each.value.az}"
      Type        = "public"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_subnet" "private" {
  for_each = {
    for idx, az in var.availability_zones :
    az => {
      cidr_block = var.private_subnet_cidrs[idx]
      az         = az
    }
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-private-${each.value.az}"
      Type        = "private"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

locals {
  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
  nat_az_keys       = slice(var.availability_zones, 0, local.nat_gateway_count)
}

resource "aws_eip" "nat" {
  for_each = toset(local.nat_az_keys)
  domain   = "vpc"

  depends_on = [aws_internet_gateway.this]

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-nat-eip-${each.value}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_nat_gateway" "this" {
  for_each = toset(local.nat_az_keys)

  allocation_id = aws_eip.nat[each.value].id
  subnet_id     = aws_subnet.public[each.value].id

  depends_on = [aws_internet_gateway.this]

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-nat-${each.value}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-public-rt"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = toset(var.availability_zones)
  vpc_id   = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.project}-${var.environment}-private-rt-${each.value}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_route" "private_nat" {
  for_each = var.enable_nat_gateway ? toset(var.availability_zones) : toset([])

  route_table_id         = aws_route_table.private[each.value].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = var.single_nat_gateway ? (
    aws_nat_gateway.this[local.nat_az_keys[0]].id
  ) : aws_nat_gateway.this[each.value].id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
