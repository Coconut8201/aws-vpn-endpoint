# AWS 設定
aws_region = "ap-northeast-1"

# 組織資訊
organization_name   = "YuZhiWang"
country             = "TW"
province            = "Taiwan"
locality            = "Taipei"
organizational_unit = "IT Department"

# VPN 伺服器設定
vpn_server_cn = "vpn-server.internal"

server_san_dns_names = [
  "server",
  "vpn.internal",
  "vpn-server.internal",
  "openvpn.internal",
  "localhost",
]

server_san_ips = [
  "127.0.0.1",
]

# 客戶端列表
client_names = [
  "coco",
  "client1",
  "client2",
  "admin",
]

# 憑證有效期（天）
certificate_validity_days = 825

# 輸出路徑
output_path = "generated"

# 是否匯入 ACM
enable_acm_import = true

# 標籤
tags = {
  Environment = "production"
  Project     = "ClientVPN"
  ManagedBy   = "Terraform"
  Owner       = "SRE Team"
}
