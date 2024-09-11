
resource "aws_eip" "this" {
  for_each = {
    for zone_name, az in var.availability_zones : zone_name => az
    if az.nat_gateway_enabled
  }
  tags = {
    "Name" = data.aws_availability_zone.this[each.key].zone_id
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "this" {
  for_each = {
    for zone_name, az in var.availability_zones : zone_name => az
    if az.nat_gateway_enabled
  }
  allocation_id = aws_eip.this[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = data.aws_availability_zone.this[each.key].zone_id
  }
}

resource "aws_route" "private_nat64" {
  for_each = {
    for zone_name, az in var.availability_zones : zone_name => az
    if az.nat_gateway_enabled && var.ipv6.enabled
  }
  route_table_id              = aws_route_table.private[each.key].id
  nat_gateway_id              = aws_nat_gateway.this[each.key].id
  destination_ipv6_cidr_block = var.ipv6.destination_cidr_block
  depends_on                  = [aws_route_table.private]
}
