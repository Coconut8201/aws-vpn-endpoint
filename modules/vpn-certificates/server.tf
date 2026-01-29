# server 私鑰
resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# server CSR
resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    country             = var.country
    province            = var.province
    locality            = var.locality
    organization        = var.organization_name
    organizational_unit = var.organizational_unit
    common_name         = var.server_cn
  }

  dns_names    = var.server_dns_names
  ip_addresses = var.server_san_ips
}

# 用 CA 簽署伺服器憑證
resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.certificate_validity_days * 24

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

# 匯入到 ACM
resource "aws_acm_certificate" "server" {
  count = var.enable_acm_import ? 1 : 0

  private_key       = tls_private_key.server.private_key_pem
  certificate_body  = tls_locally_signed_cert.server.cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem

  tags = merge(
    {
      Name      = "VPN-Server-Certificate"
      ManagedBy = "Terraform"
    },
    var.tags
  )

  # 確保新憑證建立完成後才移除舊憑證
  # 防止 VPN 服務因憑證過期而中斷
  lifecycle {
    create_before_destroy = true
  }
}

# 儲存伺服器憑證
resource "local_file" "server_cert" {
  content         = tls_locally_signed_cert.server.cert_pem
  filename        = "${var.output_path}/server/server.crt"
  file_permission = "0644"
}

resource "local_sensitive_file" "server_key" {
  content         = tls_private_key.server.private_key_pem
  filename        = "${var.output_path}/server/server.key"
  file_permission = "0600"
}
