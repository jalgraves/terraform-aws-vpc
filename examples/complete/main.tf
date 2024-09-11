
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = local.configs.region
}

locals {
  configs = {
    env         = "test"
    region      = "us-east-2"
    region_code = "use2"
  }
  azs = {
    # Availability zones
    us-east-2a = {
      nat_gateway_enabled            = true
      public_route_table_enabled     = true
      public_route_table_association = null
    }
    us-east-2b = {
      nat_gateway_enabled            = false
      public_route_table_enabled     = false
      public_route_table_association = "us-east-2a"
    }
  }
  ipv4 = {
    bits                                        = 2
    cidr_block                                  = "10.0.0.0/16"
    destination_cidr_block                      = "0.0.0.0/0"
    enable_resource_name_dns_a_record_on_launch = true
  }
  ipv6 = {
    bits                                           = 8
    assign_ipv6_address_on_creation                = true
    destination_cidr_block                         = "64:ff9b::/96"
    enabled                                        = true
    enable_dns64                                   = true
    enable_resource_name_dns_aaaa_record_on_launch = true
  }
  subnet_tags = {
    public = {
      "kubernetes.io/cluster/test-use2" = "owned"
      "kubernetes.io/role/elb"          = "1"
      "cpco.io/subnet/type"             = "public"
    }
    private = {
      "kubernetes.io/cluster/test-use2" = "owned"
      "kubernetes.io/role/internal-elb" = "1"
      "cpco.io/subnet/type"             = "private"
    }
  }
}

module "network" {
  source = "../.."

  availability_zones = local.azs
  ipv4               = local.ipv4
  ipv6               = local.ipv6
  env                = local.configs.env
  region             = local.configs.region
  region_code        = local.configs.region_code
  subnet_tags        = local.subnet_tags
}
