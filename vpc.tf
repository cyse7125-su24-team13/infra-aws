provider "aws" {
  region = local.region
  profile = var.aws_profile
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-eks-mng"
  region = "us-east-1"

  vpc_cidr = "10.1.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnet_cidrs = [
    "10.1.1.0/24",
    "10.1.2.0/24",
    "10.1.3.0/24"
  ]

  private_subnet_cidrs = [
    "10.1.4.0/24",
    "10.1.5.0/24",
    "10.1.6.0/24"
  ]

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr

  tags = merge(local.tags, {
    "Name" = local.name
  })
}

resource "aws_subnet" "public" {
  count = length(local.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(local.public_subnet_cidrs, count.index)
  availability_zone = element(local.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    "Name" = "${local.name}-public-subnet-${count.index}"
    "kubernetes.io/role/elb" = 1
  })
}

resource "aws_subnet" "private" {
  count = length(local.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(local.private_subnet_cidrs, count.index)
  availability_zone = element(local.azs, count.index)

  tags = merge(local.tags, {
    "Name" = "${local.name}-private-subnet-${count.index}"
    "kubernetes.io/role/internal-elb" = 1
  })
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, {
    "Name" = "${local.name}-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(local.tags, {
    "Name" = "${local.name}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)

  tags = merge(local.tags, {
    "Name" = "${local.name}-nat"
  })
}

resource "aws_eip" "nat" {
  vpc = true

  tags = merge(local.tags, {
    "Name" = "${local.name}-eip"
  })
}

resource "aws_route_table" "private" {
  count = length(local.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(local.tags, {
    "Name" = "${local.name}-private-rt-${count.index}"
  })
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
