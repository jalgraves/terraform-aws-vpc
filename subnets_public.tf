

resource "aws_subnet" "public" {
  for_each = {
    for zone_name, az in var.availability_zones : zone_name => az
  }
  vpc_id                                         = aws_vpc.this.id
  availability_zone                              = each.key
  cidr_block                                     = local.public_ipv4_cidrs[index(keys(var.availability_zones), each.key)]
  ipv6_cidr_block                                = var.ipv6.enabled ? local.public_ipv6_cidrs[index(keys(var.availability_zones), each.key)] : null
  assign_ipv6_address_on_creation                = var.ipv6.enabled ? var.ipv6.assign_ipv6_address_on_creation : false
  enable_dns64                                   = var.ipv6.enabled ? var.ipv6.enable_dns64 : false
  map_public_ip_on_launch                        = true
  enable_resource_name_dns_a_record_on_launch    = var.ipv4.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = var.ipv6.enabled ? var.ipv6.enable_resource_name_dns_aaaa_record_on_launch : false
  private_dns_hostname_type_on_launch            = var.private_dns_hostname_type_on_launch
  tags = merge(
    {
      "Name" = "${var.env}-${data.aws_availability_zone.this[each.key].zone_id}-public"
    },
    var.subnet_tags.public
  )
  lifecycle {
    # Ignore tags added by kops or kubernetes
    ignore_changes = [tags.kubernetes, tags.SubnetType]
  }
}

resource "aws_route_table" "public" {
  for_each = {
    for zone_name, az in var.availability_zones : zone_name => az
    if az.public_route_table_enabled
  }
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${var.env}-${data.aws_availability_zone.this[each.key].zone_id}-public"
  }
}

resource "aws_route_table_association" "public" {
  for_each = {
    for zone_name, az in var.availability_zones : zone_name => az
  }
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = each.value.public_route_table_enabled ? aws_route_table.public[each.key].id : aws_route_table.public[each.value.public_route_table_association].id
}

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = [for subnet_name, subnet in aws_subnet.public : subnet.id]

  tags = {
    "Name" = "${var.env}-${var.region_code}-public"
  }
}

resource "aws_network_acl_rule" "public4_ingress" {
  network_acl_id = aws_network_acl.public.id
  rule_action    = "allow"
  rule_number    = 100

  egress     = false
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
  protocol   = "-1"
}

resource "aws_network_acl_rule" "public4_egress" {
  network_acl_id = aws_network_acl.public.id
  rule_action    = "allow"
  rule_number    = 100

  egress     = true
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
  protocol   = "-1"
}

resource "aws_network_acl_rule" "public6_ingress" {
  count          = var.ipv6.enabled ? 1 : 0
  network_acl_id = aws_network_acl.public.id
  rule_action    = "allow"
  rule_number    = 111

  egress          = false
  ipv6_cidr_block = "::/0"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
}

resource "aws_network_acl_rule" "public6_egress" {
  count          = var.ipv6.enabled ? 1 : 0
  network_acl_id = aws_network_acl.public.id
  rule_action    = "allow"
  rule_number    = 111

  egress          = true
  ipv6_cidr_block = "::/0"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
}

resource "aws_route" "public" {
  for_each = {
    for zone_name, az in var.availability_zones : zone_name => az
    if az.public_route_table_enabled
  }
  route_table_id         = aws_route_table.public[each.key].id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = var.ipv4.destination_cidr_block
  depends_on             = [aws_route_table.public]
}
