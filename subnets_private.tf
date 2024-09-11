
resource "aws_subnet" "private" {
  for_each = {
    for zone_name, az in var.availability_zones : zone_name => az
  }
  vpc_id                                         = aws_vpc.this.id
  availability_zone                              = each.key
  cidr_block                                     = local.private_ipv4_cidrs[index(keys(var.availability_zones), each.key)]
  ipv6_cidr_block                                = var.ipv6.enabled ? local.private_ipv6_cidrs[index(keys(var.availability_zones), each.key)] : null
  assign_ipv6_address_on_creation                = var.ipv6.assign_ipv6_address_on_creation
  enable_dns64                                   = var.ipv6.enabled ? var.enable_dns64 : false
  enable_resource_name_dns_a_record_on_launch    = var.ipv4.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = var.ipv6.enabled ? var.ipv6.enable_resource_name_dns_aaaa_record_on_launch : false
  private_dns_hostname_type_on_launch            = var.private_dns_hostname_type_on_launch
  tags = merge(
    {
      "Name" = "${var.env}-${data.aws_availability_zone.this[each.key].zone_id}-private"
    },
    var.subnet_tags.private
  )
  lifecycle {
    # Ignore tags added by kops or kubernetes
    ignore_changes = [tags.kubernetes, tags.SubnetType]
  }
}

resource "aws_route_table" "private" {
  for_each = {
    for zone_name, az in var.availability_zones : zone_name => az
  }
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${var.env}-${data.aws_availability_zone.this[each.key].zone_id}-private"
  }
}

resource "aws_egress_only_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "private6" {
  for_each = {
    for zone_name, az in var.availability_zones : zone_name => az
    if az.nat_gateway_enabled && var.ipv6.enabled
  }
  route_table_id              = aws_route_table.private[each.key].id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.this.id
}

resource "aws_route" "private" {
  for_each = {
    for zone_name, az in var.availability_zones : zone_name => az
    if az.nat_gateway_enabled
  }
  route_table_id         = aws_route_table.private[each.key].id
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
  destination_cidr_block = var.ipv4.destination_cidr_block
  depends_on             = [aws_route_table.private]
}

resource "aws_route_table_association" "private" {
  for_each = {
    for zone_name, az in var.availability_zones : zone_name => az
  }
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = [for subnet_name, subnet in aws_subnet.private : subnet.id]

  tags = {
    "Name" = "${var.env}-${var.region_code}-private"
  }
}

resource "aws_network_acl_rule" "private4_ingress" {
  network_acl_id = aws_network_acl.private.id
  rule_action    = "allow"
  rule_number    = 100

  egress     = false
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
  protocol   = "-1"
}

resource "aws_network_acl_rule" "private4_egress" {
  network_acl_id = aws_network_acl.private.id
  rule_action    = "allow"
  rule_number    = 100

  egress     = true
  cidr_block = "0.0.0.0/0"
  from_port  = 0
  to_port    = 0
  protocol   = "-1"
}

resource "aws_network_acl_rule" "private6_ingress" {
  count          = var.ipv6.enabled ? 1 : 0
  network_acl_id = aws_network_acl.private.id
  rule_action    = "allow"
  rule_number    = 111

  egress          = false
  ipv6_cidr_block = "::/0"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
}

resource "aws_network_acl_rule" "private6_egress" {
  count          = var.ipv6.enabled ? 1 : 0
  network_acl_id = aws_network_acl.private.id
  rule_action    = "allow"
  rule_number    = 111

  egress          = true
  ipv6_cidr_block = "::/0"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
}
