variable "vpc_name" {
  description = "VPC Show Name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}

variable "environment" {
  description = "環境(dev/stage/prod)"
  type        = string
  default     = "dev"
}

variable "subnet_cidr" {
  description = "Subnet CIDR Block"
  type        = string
}

variable "az" {
  description = "Availability Zone"
  type        = string
  default     = "ap-northeast-1a"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "allowed_cidr_blocks" {
  description = "Additional CIDR blocks to allow in security group (e.g., other VPCs)"
  type        = list(string)
  default     = []
}

variable "enable_internet_gateway" {
  description = "是否啟用 Internet Gateway (讓 subnet 成為公開子網路)"
  type        = bool
  default     = false
}
