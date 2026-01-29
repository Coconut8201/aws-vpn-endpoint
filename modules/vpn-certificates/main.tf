terraform {
  required_version = ">= 1.0"

  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# 建立輸出目錄
resource "null_resource" "create_output_dirs" {
  provisioner "local-exec" {
    command = "mkdir -p ${var.output_path}/clients"
  }

  triggers = {
    output_path = var.output_path
  }
}
