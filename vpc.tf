provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-eks-mng"
  region = "eu-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k+21)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 31)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

resource "aws_subnet" "public" {
  count = length(module.vpc.public_subnets)
  vpc_id            = module.vpc.vpc_id
  cidr_block        = element(module.vpc.public_subnets, count.index)
  availability_zone = element(local.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    "Name" = "${local.name}-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb" = 1
  })
}