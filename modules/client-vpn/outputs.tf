output "client_vpn_endpoint_id" {
  description = "ID of the Client VPN Endpoint"
  value       = aws_ec2_client_vpn_endpoint.this.id
}

output "client_vpn_endpoint_arn" {
  description = "ARN of the Client VPN Endpoint"
  value       = aws_ec2_client_vpn_endpoint.this.arn
}

output "client_vpn_endpoint_dns_name" {
  description = "DNS name of the Client VPN Endpoint"
  value       = aws_ec2_client_vpn_endpoint.this.dns_name
}

output "security_group_id" {
  description = "ID of the Client VPN security group"
  value       = aws_security_group.client_vpn.id
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for Client VPN"
  value       = aws_cloudwatch_log_group.client_vpn_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for Client VPN"
  value       = aws_cloudwatch_log_group.client_vpn_logs.arn
}

output "network_association_ids" {
  description = "IDs of the Client VPN network associations"
  value       = aws_ec2_client_vpn_network_association.this[*].id
}

output "vpn_configuration_url" {
  description = "URL to download VPN configuration"
  value       = "Use AWS Console or CLI to download configuration for endpoint: ${aws_ec2_client_vpn_endpoint.this.id}"
}
