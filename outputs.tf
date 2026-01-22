output "ca_certificate_path" {
  description = "Path to CA certificate"
  value       = module.vpn_certificates.ca_certificate_path
}

output "server_certificate_path" {
  description = "Path to server certificate"
  value       = module.vpn_certificates.server_certificate_path
}

output "server_private_key_path" {
  description = "Path to server private key"
  value       = module.vpn_certificates.server_private_key_path
  sensitive   = true
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = module.vpn_certificates.acm_certificate_arn
}

output "acm_certificate_status" {
  description = "Status of the ACM certificate"
  value       = module.vpn_certificates.acm_certificate_status
}

output "client_certificates" {
  description = "Client certificate information"
  value       = module.vpn_certificates.client_certificates
}

output "server_san_info" {
  description = "Server certificate SAN information"
  value = {
    dns_names    = module.vpn_certificates.server_san_dns_names
    ip_addresses = module.vpn_certificates.server_san_ip_addresses
  }
}

output "summary" {
  description = "Certificate generation summary"
  value = {
    organization      = var.organization_name
    server_cn         = var.vpn_server_cn
    clients_generated = length(var.client_names)
    acm_imported      = var.enable_acm_import
    validity_days     = var.certificate_validity_days
  }
}

# ============================================
# Network Infrastructure Outputs
# ============================================

# VPC Outputs
output "network_vpc_id" {
  description = "ID of the network VPC"
  value       = module.network_vpc.vpc_id
}

output "network_vpc_cidr" {
  description = "CIDR block of the network VPC"
  value       = module.network_vpc.vpc_cidr
}

output "business_vpc_id" {
  description = "ID of the business VPC"
  value       = module.business_vpc.vpc_id
}

output "business_vpc_cidr" {
  description = "CIDR block of the business VPC"
  value       = module.business_vpc.vpc_cidr
}

# Transit Gateway Outputs
output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = module.transit_gateway.transit_gateway_id
}

# Client VPN Outputs
output "vpn_endpoint_id" {
  description = "ID of the Client VPN endpoint"
  value       = module.client_vpn.vpn_endpoint_id
}

output "vpn_endpoint_dns_name" {
  description = "DNS name of the Client VPN endpoint"
  value       = module.client_vpn.vpn_endpoint_dns_name
}

output "vpn_configuration_summary" {
  description = "VPN configuration summary"
  value = {
    endpoint_name     = var.vpn_endpoint_name
    client_cidr       = var.vpn_client_cidr
    network_vpc_cidr  = var.network_vpc_cidr
    business_vpc_cidr = var.business_vpc_cidr
    split_tunnel      = var.vpn_split_tunnel
  }
}
