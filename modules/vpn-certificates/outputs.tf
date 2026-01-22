output "ca_certificate_pem" {
  description = "CA certificate in PEM format"
  value       = tls_self_signed_cert.ca.cert_pem
}

output "ca_private_key_pem" {
  description = "CA private key in PEM format"
  value       = tls_private_key.ca.private_key_pem
  sensitive   = true
}

output "ca_certificate_path" {
  description = "Path to CA certificate file"
  value       = local_file.ca_cert.filename
}

output "server_certificate_pem" {
  description = "Server certificate in PEM format"
  value       = tls_locally_signed_cert.server.cert_pem
}

output "server_private_key_pem" {
  description = "Server private key in PEM format"
  value       = tls_private_key.server.private_key_pem
  sensitive   = true
}

output "server_certificate_path" {
  description = "Path to server certificate file"
  value       = local_file.server_cert.filename
}

output "server_private_key_path" {
  description = "Path to server private key file"
  value       = local_sensitive_file.server_key.filename
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = var.enable_acm_import ? aws_acm_certificate.server[0].arn : null
}

output "acm_certificate_id" {
  description = "ID of the ACM certificate"
  value       = var.enable_acm_import ? aws_acm_certificate.server[0].id : null
}

output "acm_certificate_status" {
  description = "Status of the ACM certificate"
  value       = var.enable_acm_import ? aws_acm_certificate.server[0].status : null
}

output "client_certificates" {
  description = "Map of client certificate paths"
  value = {
    for name in var.client_names : name => {
      certificate = local_file.client_cert[name].filename
      private_key = local_sensitive_file.client_key[name].filename
    }
  }
}

output "server_san_dns_names" {
  description = "Server certificate SAN DNS names"
  value       = concat([var.vpn_server_cn], var.server_san_dns_names)
}

output "server_san_ip_addresses" {
  description = "Server certificate SAN IP addresses"
  value       = var.server_san_ips
}
