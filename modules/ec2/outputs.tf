output "instance_id" {
  description = "EC2 實例 ID"
  value       = aws_instance.main.id
}

output "instance_private_ip" {
  description = "EC2 私有 IP 地址"
  value       = aws_instance.main.private_ip
}

output "instance_arn" {
  description = "EC2 實例 ARN"
  value       = aws_instance.main.arn
}
