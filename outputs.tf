
output "vpc" {
  value = {
    cidr_block          = aws_vpc.this.cidr_block
    id                  = aws_vpc.this.id
    nat_ips             = [for nat_name, nat in aws_nat_gateway.this : nat.allocation_id]
    ipv6_association_id = aws_vpc.this.ipv6_association_id
    ipv6_cidr_block     = aws_vpc.this.ipv6_cidr_block
  }
}

output "subnets" {
  value = {
    public = {
      ids             = [for subnet_name, subnet in aws_subnet.public : subnet.id]
      route_table_ids = [for route_table_name, route_table in aws_route_table.public : route_table.id]
      ipv4 = {
        cidr_blocks = [for subnet_name, subnet in aws_subnet.public : subnet.cidr_block]
      }
      ipv6 = {
        cidr_blocks = [for subnet_name, subnet in aws_subnet.public : subnet.ipv6_cidr_block]
      }
    }
    private = {
      ids             = [for subnet_name, subnet in aws_subnet.private : subnet.id]
      route_table_ids = [for route_table_name, route_table in aws_route_table.private : route_table.id]
      ipv4 = {
        cidrs = [for subnet_name, subnet in aws_subnet.private : subnet.cidr_block]
      }
      ipv6 = {
        cidrs = [for subnet_name, subnet in aws_subnet.private : subnet.ipv6_cidr_block]
      }
    }
    # legacy outputs
    # TODO: cleanup after clusters have been migrated
    private_subnet_private_route_table_ids = [for route_table_name, route_table in aws_route_table.private : route_table.id]
    private_subnet_ids                     = [for subnet_name, subnet in aws_subnet.private : subnet.id]
    private_subnet_cidrs                   = [for subnet_name, subnet in aws_subnet.public : subnet.cidr_block]
    public_route_table_ids                 = [for route_table_name, route_table in aws_route_table.public : route_table.id]
    public_subnet_ids                      = [for subnet_name, subnet in aws_subnet.public : subnet.id]
    public_subnet_cidrs                    = [for subnet_name, subnet in aws_subnet.public : subnet.cidr_block]
  }
}

output "availability_zones" {
  value = {
    for az_name, az in var.availability_zones : az_name => {
      zone_id = data.aws_availability_zone.this[az_name].zone_id
      region  = data.aws_availability_zone.this[az_name].region
      subnets = {
        private = aws_subnet.private[az_name]
        public  = aws_subnet.public[az_name]
      }
    }
  }
}
