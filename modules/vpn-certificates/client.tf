# 客戶端私鑰
resource "tls_private_key" "client" {
  for_each = toset(var.client_names)

  algorithm = "RSA"
  rsa_bits  = 2048
}

# 客戶端 CSR
resource "tls_cert_request" "client" {
  for_each = toset(var.client_names)

  private_key_pem = tls_private_key.client[each.key].private_key_pem

  subject {
    country             = var.country
    province            = var.province
    locality            = var.locality
    organization        = var.organization_name
    organizational_unit = var.organizational_unit
    common_name         = each.key
  }

  dns_names = [each.key]
}

# 用 CA 簽署客戶端憑證
resource "tls_locally_signed_cert" "client" {
  for_each = toset(var.client_names)

  cert_request_pem   = tls_cert_request.client[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.certificate_validity_days * 24

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

# 儲存客戶端憑證
resource "local_file" "client_cert" {
  for_each = toset(var.client_names)

  content         = tls_locally_signed_cert.client[each.key].cert_pem
  filename        = "${var.output_path}/clients/${each.key}.crt"
  file_permission = "0644"
}

resource "local_sensitive_file" "client_key" {
  for_each = toset(var.client_names)

  content         = tls_private_key.client[each.key].private_key_pem
  filename        = "${var.output_path}/clients/${each.key}.key"
  file_permission = "0600"
}
