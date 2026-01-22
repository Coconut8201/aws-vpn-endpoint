variable "vpn_endpoint_name" {
  description = "Name of the Client VPN endpoint"
  type        = string
}

variable "description" {
  description = "Description of the Client VPN endpoint"
  type        = string
  default     = "Client VPN Endpoint"
}

variable "vpc_id" {
  description = "ID of the VPC to associate with the Client VPN"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with the Client VPN"
  type        = list(string)
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
  description = "Enable split tunnel mode"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
