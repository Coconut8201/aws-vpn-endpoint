variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-1"
}

variable "organization_name" {
  description = "Organization name for certificates"
  type        = string
  default     = "YuZhiWang"
}

variable "country" {
  description = "Country code"
  type        = string
  default     = "TW"
}

variable "province" {
  description = "Province or State"
  type        = string
  default     = "Taiwan"
}

variable "locality" {
  description = "City or Locality"
  type        = string
  default     = "Taipei"
}

variable "organizational_unit" {
  description = "Organizational Unit"
  type        = string
  default     = "IT Department"
}

variable "vpn_server_cn" {
  description = "Common Name for VPN server"
  type        = string
  default     = "vpn-server.internal"
}

variable "server_san_dns_names" {
  description = "Additional DNS names for server certificate SAN"
  type        = list(string)
  default = [
    "server",
    "vpn.internal",
    "vpn-server.internal",
    "localhost",
  ]
}

variable "server_san_ips" {
  description = "IP addresses for server certificate SAN"
  type        = list(string)
  default     = ["127.0.0.1"]
}

variable "client_names" {
  description = "List of client names to generate certificates for"
  type        = list(string)
  default     = ["client1", "client2", "client3"]
}

variable "certificate_validity_days" {
  description = "Certificate validity period in days"
  type        = number
  default     = 825
}

variable "output_path" {
  description = "Path to store generated certificates"
  type        = string
  default     = "generated"
}

variable "enable_acm_import" {
  description = "Whether to import server certificate to ACM"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "VPN"
  }
}

# ============================================
# Network Infrastructure Variables
# ============================================

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

# Network VPC
variable "network_vpc_cidr" {
  description = "CIDR block for network VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "network_private_subnet_cidrs" {
  description = "CIDR blocks for network VPC private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Business VPC
variable "business_vpc_cidr" {
  description = "CIDR block for business VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "business_private_subnet_cidrs" {
  description = "CIDR blocks for business VPC private subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

# Client VPN
variable "vpn_endpoint_name" {
  description = "Name of the Client VPN endpoint"
  type        = string
  default     = "main-client-vpn"
}

variable "vpn_client_cidr" {
  description = "CIDR block for VPN clients"
  type        = string
  default     = "172.16.0.0/22"
}

variable "vpn_dns_servers" {
  description = "DNS servers for VPN clients"
  type        = list(string)
  default     = []
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
