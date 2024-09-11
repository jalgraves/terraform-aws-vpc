
data "aws_availability_zone" "this" {
  for_each = {
    for zone_name, az in var.availability_zones : zone_name => az
  }
  name = each.key
}

data "aws_region" "current" {}

locals {
  total_subnet_count = length(keys(var.availability_zones)) * 2
  ipv4_cidrs         = [for index in range(local.total_subnet_count) : cidrsubnet(aws_vpc.this.cidr_block, var.ipv4.bits, index)]
  ipv6_cidrs         = [for index in range(local.total_subnet_count) : cidrsubnet(aws_vpc.this.ipv6_cidr_block, var.ipv6.bits, index)]
  public_ipv4_cidrs  = slice(local.ipv4_cidrs, 0, length(keys(var.availability_zones)))
  private_ipv4_cidrs = slice(local.ipv4_cidrs, length(keys(var.availability_zones)), local.total_subnet_count)
  public_ipv6_cidrs  = slice(local.ipv6_cidrs, 0, length(keys(var.availability_zones)))
  private_ipv6_cidrs = slice(local.ipv6_cidrs, length(keys(var.availability_zones)), local.total_subnet_count)
}

resource "aws_vpc" "this" {
  cidr_block                       = var.ipv4.cidr_block
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block
  tags = {
    "Name" = "${var.env}-${var.region_code}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${var.env}-${var.region_code}"
  }
}
