variable "organization_name" {
  description = "Organization name for certificates"
  type        = string
}

variable "output_path" {
  description = "Path to store generated certificates"
  type        = string
  default     = "generated"
}

variable "country" {
  description = "Country code (e.g., TW)"
  type        = string
  default     = "TW"
}

variable "province" {
  description = "State or Province"
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

variable "certificate_validity_days" {
  description = "Certificate validity period in days"
  type        = number
  default     = 825
}

variable "server_cn" {
  description = "Common Name for VPN server certificate"
  type        = string
}

variable "server_dns_names" {
  description = "DNS names for VPN server certificate"
  type        = list(string)
}

variable "server_san_ips" {
  description = "IP addresses for server certificate SAN"
  type        = list(string)
}

variable "enable_acm_import" {
  description = "Whether to import server certificate to ACM"
  type        = bool
  default     = true
}


variable "tags" {
  description = "Tags to apply to ACM certificate"
  type        = map(string)
  default     = {}
}

variable "client_names" {
  description = "List of client names to generate certificates for"
  type        = list(string)
}
