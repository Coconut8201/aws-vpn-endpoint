output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.arn
}

output "vpc_attachment_ids" {
  description = "IDs of VPC attachments"
  value       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.this : k => v.id }
}
