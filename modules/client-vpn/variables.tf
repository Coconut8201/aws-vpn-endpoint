variable "output_path" {
  description = "Path to store generated certificates"
  type        = string
  default     = "generated"
}

variable "client_vpn_name" {
  description = "the name for client vpn"
  type        = string
  default     = "client-vpn"
}

variable "log_retention_days" {
  description = "Retention period for CloudWatch Logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to ACM certificate"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "ID of the VPC to associate with the Client VPN"
  type        = string
}

variable "client_cidr_block" {
  description = "CIDR block for VPN clients"
  type        = string
}

variable "server_certificate_arn" {
  description = "ARN of the server certificate in ACM"
  type        = string
}

variable "root_certificate_arn" {
  description = "ARN of the root CA certificate in ACM"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers for VPN clients"
  type        = list(string)
  default     = []
}

variable "split_tunnel" {
  description = "Enable split tunneling"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the Client VPN"
  type        = list(string)
}

variable "additional_cidrs" {
  description = "Additional CIDR blocks to authorize"
  type        = list(string)
  default     = []
}

variable "vpn_routes" {
  description = "Map of VPN routes"
  type = map(object({
    destination_cidr = string
    description      = string
  }))
  default = {}
}
