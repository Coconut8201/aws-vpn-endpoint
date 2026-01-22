variable "tgw_name" {
  description = "Name of the Transit Gateway"
  type        = string
}

variable "description" {
  description = "Description of the Transit Gateway"
  type        = string
  default     = "Transit Gateway for VPC connectivity"
}

variable "vpc_attachments" {
  description = "Map of VPC attachments"
  type = map(object({
    vpc_id     = string
    subnet_ids = list(string)
  }))
  default = {}
}

variable "tgw_routes" {
  description = "Map of routes to Transit Gateway"
  type = map(object({
    route_table_id   = string
    destination_cidr = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
