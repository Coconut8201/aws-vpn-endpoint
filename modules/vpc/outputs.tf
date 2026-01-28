output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.this.cidr_block
}

output "vpc_arn" {
  description = "VPC ARN"
  value       = aws_vpc.this.arn
}

output "subnet_id" {
  description = "Subnet ID"
  value       = aws_subnet.this.id
}

output "subnet_cidr" {
  description = "Subnet CIDR block"
  value       = aws_subnet.this.cidr_block
}

output "subnet_az" {
  description = "Subnet availability zone"
  value       = aws_subnet.this.availability_zone
}

output "route_table_id" {
  description = "Route table ID"
  value       = aws_route_table.this.id
}

output "default_security_group_id" {
  description = "Default security group ID"
  value       = aws_security_group.default.id
}
