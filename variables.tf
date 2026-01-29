# AWS 可用區域設定
variable "az" {
  description = "alivanle zone"
  type        = string
  default     = "ap-northeast-1a"
}

# Network VPC
variable "network_vpc_cidr" {
  description = "CIDR block for network VPC"
  type        = string
  default     = "10.4.0.0/16"
}

variable "network_private_subnet_cidrs" {
  description = "CIDR blocks for network VPC private subnets"
  type        = string
  default     = "10.4.1.0/24"
}

# Business VPC
variable "business_vpc_cidr" {
  description = "CIDR block for business VPC"
  type        = string
  default     = "10.5.0.0/16"
}

variable "business_private_subnet_cidrs" {
  description = "CIDR blocks for business VPC private subnets"
  type        = string
  default     = "10.5.1.0/24"
}


# SSL/TLS 憑證組織資訊
variable "organization_name" {
  description = "Organization name for certificates"
  type        = string
  default     = "YuZhiWang"
}

# 憑證國家代碼
variable "country" {
  description = "Country code"
  type        = string
  default     = "TW"
}

# 憑證省份/州名
variable "province" {
  description = "Province or State"
  type        = string
  default     = "Taiwan"
}

# 憑證城市名稱
variable "locality" {
  description = "City or Locality"
  type        = string
  default     = "Taipei"
}

# 憑證組織單位
variable "organizational_unit" {
  description = "Organizational Unit"
  type        = string
  default     = "IT Department"
}

# VPN 伺服器通用名稱
variable "vpn_server_cn" {
  description = "Common Name for VPN server"
  type        = string
  default     = "vpn-server.internal"
}

# VPN 伺服器 DNS 名稱
variable "vpn_server_dns_names" {
  description = "DNS names for VPN server certificate"
  type        = list(string)
  default     = ["vpn-server-0126.internal"]
}

# VPN 伺服器 憑證 SAN IP
variable "vpn_server_san_ips" {
  description = "IP addresses for VPN server certificate SAN"
  type        = list(string)
  default     = ["127.0.0.1"]
}

variable "client_names" {
  description = "List of client names to generate certificates for"
  type        = list(string)
  default     = ["client"]
}

# 憑證有效期限
variable "certificate_validity_days" {
  description = "Certificate validity period in days"
  type        = number
  default     = 365
}

# 憑證輸出路徑
variable "output_path" {
  description = "Output path for certificates"
  type        = string
  default     = "./certificates"
}

# AWS 區域
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

# 是否啟用 ACM 匯入
variable "enable_acm_import" {
  description = "Enable ACM certificate import"
  type        = bool
  default     = true
}

# 資源標籤
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "development"
    ManagedBy   = "Terraform"
  }
}

# Client VPN Name
variable "client_vpn_name" {
  description = "Name of the Client VPN endpoint"
  type        = string
  default     = "main-client-vpn"
}

variable "vpn_client_cidr" {
  description = "CIDR block for VPN clients"
  type        = string
  default     = "10.101.0.0/16"
}

variable "vpn_dns_servers" {
  description = "DNS servers for VPN clients"
  type        = list(string)
  default     = ["8.8.8.8"]
}

variable "vpn_split_tunnel" {
  description = "Enable split tunnel mode for VPN"
  type        = bool
  default     = true
}

variable "vpn_log_retention_days" {
  description = "CloudWatch log retention days for VPN"
  type        = number
  default     = 7
}

# 專案名稱
variable "project_name" {
  description = "專案名稱"
  type        = string
  default     = "aws-vpn"
}

# 環境名稱
variable "environment" {
  description = "環境名稱 (dev/staging/prod)"
  type        = string
  default     = "dev"
}

# EC2 實例類型
variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# EC2 SSH Key Pair 名稱
variable "ec2_key_name" {
  description = "EC2 SSH Key Pair 名稱（對應你的 .pem 檔案）"
  type        = string
  default     = "coco-aws-test-pem"
}

# EC2 根卷大小
variable "ec2_root_volume_size" {
  description = "EC2 根卷大小 (GB)"
  type        = number
  default     = 8
}
