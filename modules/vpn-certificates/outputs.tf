output "server_certificate_arn" {
  description = "ARN of the server certificate in ACM"
  value       = var.enable_acm_import ? aws_acm_certificate.server[0].arn : null
}

output "server_certificate_id" {
  description = "ID of the server certificate in ACM"
  value       = var.enable_acm_import ? aws_acm_certificate.server[0].id : null
}

output "ca_cert_pem" {
  description = "CA certificate in PEM format"
  value       = tls_self_signed_cert.ca.cert_pem
  sensitive   = true
}

output "server_cert_pem" {
  description = "Server certificate in PEM format"
  value       = tls_locally_signed_cert.server.cert_pem
  sensitive   = true
}

output "server_key_pem" {
  description = "Server private key in PEM format"
  value       = tls_private_key.server.private_key_pem
  sensitive   = true
}

output "client_certificates" {
  description = "Map of client names to certificate PEMs"
  value = {
    for name in var.client_names :
    name => tls_locally_signed_cert.client[name].cert_pem
  }
  sensitive = true
}

output "client_private_keys" {
  description = "Map of client names to private key PEMs"
  value = {
    for name in var.client_names :
    name => tls_private_key.client[name].private_key_pem
  }
  sensitive = true
}

output "certificate_files" {
  description = "Paths to generated certificate files"
  value = {
    ca_cert     = "${var.output_path}/ca.crt"
    ca_key      = "${var.output_path}/ca.key"
    server_cert = "${var.output_path}/server/server.crt"
    server_key  = "${var.output_path}/server/server.key"
    client_dir  = "${var.output_path}/clients"
  }
}
