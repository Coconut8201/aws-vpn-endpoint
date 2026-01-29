# Transit Gateway

resource "aws_ec2_transit_gateway" "this" {
  description                     = "Transit Gateway for AWS VPN Endpoint"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(
    var.tags, {
      Name = var.tgw_name
    }
  )
}

# Transit Gateway Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = var.vpc_attachments

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.subnet_ids
  dns_support        = "enable"

  tags = merge(
    var.tags,
    {
      Name = "${var.tgw_name}-${each.key}"
    }
  )
}

# Routes to Transit Gateway
resource "aws_route" "to_tgw" {
  for_each = var.tgw_routes

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.this.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]
}
