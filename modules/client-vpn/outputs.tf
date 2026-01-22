output "vpn_endpoint_id" {
  description = "ID of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.this.id
}

output "vpn_endpoint_arn" {
  description = "ARN of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.this.arn
}

output "vpn_endpoint_dns_name" {
  description = "DNS name of the Client VPN endpoint"
  value       = aws_ec2_client_vpn_endpoint.this.dns_name
}

output "security_group_id" {
  description = "ID of the VPN security group"
  value       = aws_security_group.vpn.id
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.vpn.name
}
