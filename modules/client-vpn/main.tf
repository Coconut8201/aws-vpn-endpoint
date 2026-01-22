# CloudWatch Log Group for Client VPN
resource "aws_cloudwatch_log_group" "vpn" {
  name              = "/aws/clientvpn/${var.vpn_endpoint_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_stream" "vpn" {
  name           = "connection-log"
  log_group_name = aws_cloudwatch_log_group.vpn.name
}

# Security Group for Client VPN
resource "aws_security_group" "vpn" {
  name_prefix = "${var.vpn_endpoint_name}-"
  description = "Security group for Client VPN endpoint"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpn_endpoint_name}-sg"
    }
  )
}

resource "aws_security_group_rule" "vpn_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.client_cidr_block]
  security_group_id = aws_security_group.vpn.id
  description       = "Allow traffic from VPN clients"
}

resource "aws_security_group_rule" "vpn_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpn.id
  description       = "Allow all outbound traffic"
}

# Client VPN Endpoint
resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = var.description
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr_block

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.root_certificate_arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn.name
  }

  dns_servers         = var.dns_servers
  split_tunnel        = var.split_tunnel
  vpc_id              = var.vpc_id
  security_group_ids  = [aws_security_group.vpn.id]
  self_service_portal = "disabled"

  transport_protocol = "udp"
  vpn_port           = 443

  tags = merge(
    var.tags,
    {
      Name = var.vpn_endpoint_name
    }
  )
}

# Network Association
resource "aws_ec2_client_vpn_network_association" "this" {
  count                  = length(var.subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = var.subnet_ids[count.index]
}

# Authorization Rules
resource "aws_ec2_client_vpn_authorization_rule" "all" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
  description            = "Allow all authenticated clients"

  depends_on = [aws_ec2_client_vpn_network_association.this]
}

# Additional Authorization Rules for specific CIDRs
resource "aws_ec2_client_vpn_authorization_rule" "additional" {
  for_each = toset(var.additional_cidrs)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = each.value
  authorize_all_groups   = true
  description            = "Allow access to ${each.value}"

  depends_on = [aws_ec2_client_vpn_network_association.this]
}

# Routes
resource "aws_ec2_client_vpn_route" "this" {
  for_each = var.vpn_routes

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  destination_cidr_block = each.value.destination_cidr
  target_vpc_subnet_id   = var.subnet_ids[0]
  description            = each.value.description

  depends_on = [aws_ec2_client_vpn_network_association.this]
}
