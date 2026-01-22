terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 調用 VPN 憑證模組
module "vpn_certificates" {
  source = "./modules/vpn-certificates"

  # 組織資訊
  organization_name   = var.organization_name
  country             = var.country
  province            = var.province
  locality            = var.locality
  organizational_unit = var.organizational_unit

  # 伺服器憑證設定
  vpn_server_cn        = var.vpn_server_cn
  server_san_dns_names = var.server_san_dns_names
  server_san_ips       = var.server_san_ips

  # 客戶端設定
  client_names = var.client_names

  # 有效期
  certificate_validity_days = var.certificate_validity_days

  # 輸出路徑
  output_path = var.output_path

  # ACM 設定
  aws_region        = var.aws_region
  enable_acm_import = var.enable_acm_import

  # 標籤
  tags = var.tags
}

# 建立輸出目錄
resource "null_resource" "create_directories" {
  provisioner "local-exec" {
    command = "mkdir -p ${var.output_path}/clients"
  }

  triggers = {
    always_run = timestamp()
  }
}

# ============================================
# Network Infrastructure
# ============================================

# Network VPC (Client VPN 所在的 VPC)
module "network_vpc" {
  source = "./modules/vpc"

  vpc_name             = "network-vpc"
  vpc_cidr             = var.network_vpc_cidr
  private_subnet_cidrs = var.network_private_subnet_cidrs
  availability_zones   = var.availability_zones

  tags = merge(
    var.tags,
    {
      VPCType = "network"
      Purpose = "client-vpn"
    }
  )
}

# Business VPC (目標服務所在的 VPC)
module "business_vpc" {
  source = "./modules/vpc"

  vpc_name             = "business-vpc"
  vpc_cidr             = var.business_vpc_cidr
  private_subnet_cidrs = var.business_private_subnet_cidrs
  availability_zones   = var.availability_zones

  tags = merge(
    var.tags,
    {
      VPCType = "business"
      Purpose = "application"
    }
  )
}

# Transit Gateway
module "transit_gateway" {
  source = "./modules/transit-gateway"

  tgw_name    = "main-tgw"
  description = "Transit Gateway connecting network-vpc and business-vpc"

  vpc_attachments = {
    network = {
      vpc_id     = module.network_vpc.vpc_id
      subnet_ids = module.network_vpc.private_subnet_ids
    }
    business = {
      vpc_id     = module.business_vpc.vpc_id
      subnet_ids = module.business_vpc.private_subnet_ids
    }
  }

  tgw_routes = {
    network_to_business = {
      route_table_id   = module.network_vpc.private_route_table_id
      destination_cidr = var.business_vpc_cidr
    }
    business_to_network = {
      route_table_id   = module.business_vpc.private_route_table_id
      destination_cidr = var.network_vpc_cidr
    }
    business_to_vpn_clients = {
      route_table_id   = module.business_vpc.private_route_table_id
      destination_cidr = var.vpn_client_cidr
    }
  }

  tags = var.tags

  depends_on = [
    module.network_vpc,
    module.business_vpc
  ]
}

# Client VPN Endpoint
module "client_vpn" {
  source = "./modules/client-vpn"

  vpn_endpoint_name      = var.vpn_endpoint_name
  description            = "AWS Client VPN for secure remote access"
  vpc_id                 = module.network_vpc.vpc_id
  subnet_ids             = module.network_vpc.private_subnet_ids
  client_cidr_block      = var.vpn_client_cidr
  server_certificate_arn = module.vpn_certificates.acm_certificate_arn
  root_certificate_arn   = module.vpn_certificates.acm_certificate_arn
  dns_servers            = var.vpn_dns_servers
  split_tunnel           = var.vpn_split_tunnel
  log_retention_days     = var.vpn_log_retention_days

  additional_cidrs = [
    var.network_vpc_cidr,
    var.business_vpc_cidr
  ]

  vpn_routes = {
    to_business_vpc = {
      destination_cidr = var.business_vpc_cidr
      description      = "Route to business VPC via Transit Gateway"
    }
  }

  tags = var.tags

  depends_on = [
    module.vpn_certificates,
    module.network_vpc,
    module.transit_gateway
  ]
}
