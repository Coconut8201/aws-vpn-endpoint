# Network VPC (Client VPN 所在的 VPC)
module "network_vpc" {
  source = "./modules/vpc"

  vpc_name    = "network-vpc-0126"
  vpc_cidr    = var.network_vpc_cidr
  subnet_cidr = var.network_private_subnet_cidrs
  az          = var.az

  # 允許來自 Business VPC 和 VPN clients 的流量
  allowed_cidr_blocks = [
    var.business_vpc_cidr,
    var.vpn_client_cidr
  ]

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

  vpc_name    = "business-vpc-0126"
  vpc_cidr    = var.business_vpc_cidr
  subnet_cidr = var.business_private_subnet_cidrs
  az          = var.az

  # 允許來自 Network VPC 和 VPN clients 的流量
  allowed_cidr_blocks = [
    var.network_vpc_cidr,
    var.vpn_client_cidr
  ]

  tags = merge(
    var.tags,
    {
      VPCType = "business"
      Purpose = "application"
    }
  )
}

# vpn_certificates
module "vpn_certificates" {
  source = "./modules/vpn-certificates"

  # 組織資訊
  organization_name   = var.organization_name
  country             = var.country
  province            = var.province
  locality            = var.locality
  organizational_unit = var.organizational_unit

  # 伺服器憑證設定
  server_cn        = var.vpn_server_cn
  server_dns_names = var.vpn_server_dns_names
  server_san_ips   = var.vpn_server_san_ips


  # 客戶端設定
  client_names = var.client_names

  # 有效期
  certificate_validity_days = var.certificate_validity_days

  # 輸出路徑
  output_path = var.output_path

  # ACM 設定
  enable_acm_import = var.enable_acm_import

  # 標籤
  tags = var.tags
}

# Transit Gateway
module "transit_gateway" {
  source = "./modules/transit-gateway"

  tgw_name = "main-tgw"

  vpc_attachments = {
    network = {
      vpc_id     = module.network_vpc.vpc_id
      subnet_ids = [module.network_vpc.subnet_id]
    }
    business = {
      vpc_id     = module.business_vpc.vpc_id
      subnet_ids = [module.business_vpc.subnet_id]
    }
  }

  tgw_routes = {
    network_to_business = {
      route_table_id   = module.network_vpc.route_table_id
      destination_cidr = var.business_vpc_cidr
    }
    network_to_vpn_clients = {
      route_table_id   = module.network_vpc.route_table_id
      destination_cidr = var.vpn_client_cidr
    }
    business_to_network = {
      route_table_id   = module.business_vpc.route_table_id
      destination_cidr = var.network_vpc_cidr
    }
    business_to_vpn_clients = {
      route_table_id   = module.business_vpc.route_table_id
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

  client_vpn_name        = var.client_vpn_name
  vpc_id                 = module.network_vpc.vpc_id
  subnet_ids             = [module.network_vpc.subnet_id]
  client_cidr_block      = var.vpn_client_cidr
  server_certificate_arn = module.vpn_certificates.server_certificate_arn
  root_certificate_arn   = module.vpn_certificates.server_certificate_arn
  dns_servers            = var.vpn_dns_servers
  split_tunnel           = var.vpn_split_tunnel
  log_retention_days     = var.vpn_log_retention_days

  # 使用 module outputs 而非 variables,確保使用實際創建的 VPC CIDR
  additional_cidrs = [
    module.network_vpc.vpc_cidr,
    module.business_vpc.vpc_cidr
  ]

  vpn_routes = {
    to_business_vpc = {
      destination_cidr = module.business_vpc.vpc_cidr
      description      = "Route to business VPC via Transit Gateway"
    }
  }

  tags = var.tags

  depends_on = [
    module.vpn_certificates,
    module.network_vpc,
    module.business_vpc,
    module.transit_gateway
  ]
}

# Network VPC EC2 Instance
module "network_ec2" {
  source = "./modules/ec2"

  project_name       = var.project_name
  environment        = var.environment
  vpc_type           = "network"
  instance_type      = var.ec2_instance_type
  subnet_id          = module.network_vpc.subnet_id
  security_group_ids = [module.network_vpc.default_security_group_id]
  key_name           = var.ec2_key_name
  root_volume_size   = var.ec2_root_volume_size

  tags = merge(
    var.tags,
    {
      Purpose = "Network VPC Instance"
      VPCType = "network"
    }
  )

  depends_on = [module.network_vpc]
}

# Business VPC EC2 Instance
module "business_ec2" {
  source = "./modules/ec2"

  project_name       = var.project_name
  environment        = var.environment
  vpc_type           = "business"
  instance_type      = var.ec2_instance_type
  subnet_id          = module.business_vpc.subnet_id
  security_group_ids = [module.business_vpc.default_security_group_id]
  key_name           = var.ec2_key_name
  root_volume_size   = var.ec2_root_volume_size

  # user_data = <<-EOF
  #   #!/bin/bash
  #   yum update -y
  #   yum install -y httpd
  #   systemctl start httpd
  #   systemctl enable httpd
  #   echo "<h1>Business VPC - Application Server</h1>" > /var/www/html/index.html
  #   echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
  # EOF

  tags = merge(
    var.tags,
    {
      Purpose = "Application Server"
      VPCType = "business"
    }
  )

  depends_on = [module.business_vpc]
}

# 執行下載 client VPN Endpoint 的腳本
resource "null_resource" "run_script" {
  provisioner "local-exec" {
    command = <<-EOT
      bash ${path.module}/scripts/setup-client-vpn-config.sh && \
      bash ${path.module}/scripts/download_client_vpn_endpoint.sh
    EOT
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [module.client_vpn]
}
