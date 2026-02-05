variable "project_name" {
  description = "專案名稱"
  type        = string
}

variable "environment" {
  description = "環境 (dev/staging/prod)"
  type        = string
}

variable "vpc_type" {
  description = "VPC 類型 (network/business)"
  type        = string
  validation {
    condition     = contains(["network", "business"], var.vpc_type)
    error_message = "vpc_type must be either 'network' or 'business'."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for EC2 instance"
  type        = list(string)
}

variable "key_name" {
  description = "SSH Key Pair 名稱（.pem 檔案對應的 Key Pair 名稱）"
  type        = string
}

variable "root_volume_size" {
  description = "根卷大小 (GB)"
  type        = number
  default     = 20
}

variable "user_data" {
  description = "EC2 啟動時執行的腳本"
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "是否分配公開 IP 地址"
  type        = bool
  default     = false
}

variable "tags" {
  description = "額外的標籤"
  type        = map(string)
  default     = {}
}
