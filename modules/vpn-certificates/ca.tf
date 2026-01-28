# CA 私鑰
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 自簽名 CA 憑證
resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    country             = var.country
    province            = var.province
    locality            = var.locality
    organization        = var.organization_name
    organizational_unit = var.organizational_unit
    common_name         = "${var.organization_name} CA"
  }

  validity_period_hours = var.certificate_validity_days * 24
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

# 儲存 CA 憑證
resource "local_file" "ca_cert" {
  content         = tls_self_signed_cert.ca.cert_pem
  filename        = "${var.output_path}/ca.crt"
  file_permission = "0644"
}

resource "local_sensitive_file" "ca_key" {
  content         = tls_private_key.ca.private_key_pem
  filename        = "${var.output_path}/ca.key"
  file_permission = "0600"
}
