# Network VPC 詳細資訊
output "network_vpc_id" {
  description = "Network VPC ID"
  value       = module.network_vpc.vpc_id
}

output "network_vpc_cidr" {
  description = "Network VPC CIDR block"
  value       = module.network_vpc.vpc_cidr
}

output "network_subnet_id" {
  description = "Network VPC subnet ID"
  value       = module.network_vpc.subnet_id
}

output "network_route_table_id" {
  description = "Network VPC route table ID"
  value       = module.network_vpc.route_table_id
}

output "network_security_group_id" {
  description = "Network VPC default security group ID"
  value       = module.network_vpc.default_security_group_id
}

# Business VPC 詳細資訊
output "business_vpc_id" {
  description = "Business VPC ID"
  value       = module.business_vpc.vpc_id
}

output "business_vpc_cidr" {
  description = "Business VPC CIDR block"
  value       = module.business_vpc.vpc_cidr
}

output "business_subnet_id" {
  description = "Business VPC subnet ID"
  value       = module.business_vpc.subnet_id
}

output "business_route_table_id" {
  description = "Business VPC route table ID"
  value       = module.business_vpc.route_table_id
}

output "business_security_group_id" {
  description = "Business VPC default security group ID"
  value       = module.business_vpc.default_security_group_id
}

# VPN Certificates
output "vpn_server_certificate_arn" {
  description = "ARN of the VPN server certificate in ACM"
  value       = module.vpn_certificates.server_certificate_arn
}

output "vpn_certificate_files" {
  description = "Paths to generated VPN certificate files"
  value       = module.vpn_certificates.certificate_files
}

# Client VPN
output "client_vpn_endpoint_id" {
  description = "ID of the Client VPN Endpoint"
  value       = module.client_vpn.client_vpn_endpoint_id
}

output "client_vpn_endpoint_dns_name" {
  description = "DNS name of the Client VPN Endpoint"
  value       = module.client_vpn.client_vpn_endpoint_dns_name
}

output "client_vpn_security_group_id" {
  description = "ID of the Client VPN security group"
  value       = module.client_vpn.security_group_id
}

output "client_vpn_configuration_url" {
  description = "Instructions to download VPN configuration"
  value       = module.client_vpn.vpn_configuration_url
}

# Network VPC EC2 Instance
output "network_ec2_instance_id" {
  description = "Network VPC EC2 實例 ID"
  value       = module.network_ec2.instance_id
}

output "network_ec2_private_ip" {
  description = "Network VPC EC2 私有 IP 地址"
  value       = module.network_ec2.instance_private_ip
}

# Business VPC EC2 Instance
output "business_ec2_instance_id" {
  description = "Business VPC EC2 實例 ID"
  value       = module.business_ec2.instance_id
}

output "business_ec2_private_ip" {
  description = "Business VPC EC2 私有 IP 地址"
  value       = module.business_ec2.instance_private_ip
}
