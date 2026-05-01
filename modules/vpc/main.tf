# Dynamically fetch available AZs in the selected region
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Use provided AZs, or fall back to all available AZs in the region
  azs = length(var.availability_zones) > 0 ? var.availability_zones : data.aws_availability_zones.available.names

  # Create a map of public subnets keyed by availability zone
  public_subnets = zipmap(
    local.azs,
    var.public_subnet_cidrs
  )

  # Create a map of private subnets keyed by availability zone
  private_subnets = zipmap(
    local.azs,
    var.private_subnet_cidrs
  )

  common_tags = merge(
    {
      Name        = var.vpc_name
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

# -------------------------------------------------------------------
# VPC
# -------------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, { Name = var.vpc_name })
}

# -------------------------------------------------------------------
# Public Subnets
# -------------------------------------------------------------------
resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, { Name = "${var.vpc_name}-public-${each.key}" })
}

# -------------------------------------------------------------------
# Internet Gateway
# -------------------------------------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, { Name = "${var.vpc_name}-igw" })
}

# -------------------------------------------------------------------
# Public Route Table
# -------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.common_tags, { Name = "${var.vpc_name}-public-rt" })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# -------------------------------------------------------------------
# Private Subnets
# -------------------------------------------------------------------
resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(local.common_tags, { Name = "${var.vpc_name}-private-${each.key}" })
}

# -------------------------------------------------------------------
# NAT Gateways
# -------------------------------------------------------------------
resource "aws_nat_gateway" "this" {
  for_each = var.enable_nat_gateway ? (
    var.single_nat_gateway ?
    { (keys(local.public_subnets)[0]) = values(local.public_subnets)[0] } :
    local.public_subnets
  ) : {}

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = var.single_nat_gateway ? aws_subnet.public[keys(local.public_subnets)[0]].id : aws_subnet.public[each.key].id

  tags = merge(local.common_tags, { Name = "${var.vpc_name}-nat-${each.key}" })

  depends_on = [aws_internet_gateway.this]
}

# -------------------------------------------------------------------
# Elastic IPs for NAT Gateways
# -------------------------------------------------------------------
resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? (
    var.single_nat_gateway ?
    { (keys(local.public_subnets)[0]) = values(local.public_subnets)[0] } :
    local.public_subnets
  ) : {}

  domain = "vpc"

  tags = merge(local.common_tags, { Name = "${var.vpc_name}-eip-${each.key}" })

  depends_on = [aws_internet_gateway.this]
}


# -------------------------------------------------------------------
# Private Route Tables (one per NAT Gateway, or one shared)
# -------------------------------------------------------------------
resource "aws_route_table" "private" {
  for_each = local.private_subnets
  vpc_id   = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[keys(local.public_subnets)[0]].id : aws_nat_gateway.this[each.key].id
    }
  }

  tags = merge(local.common_tags, { Name = "${var.vpc_name}-private-rt-${each.key}" })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
