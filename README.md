# AWS Client VPN with Transit Gateway

使用 Terraform 部署的 AWS Client VPN 解決方案，實現安全的遠端存取。

## 架構概覽

```
遠端用戶
    ↓
Client VPN Endpoint (憑證認證)
    ↓
Network VPC (10.0.0.0/16)
    ↓
Transit Gateway
    ↓
Business VPC (10.1.0.0/16)
    ↓
應用服務 (未來部署)
```

## 主要特性

- ✅ **雙 VPC 架構**: Network VPC 和 Business VPC 完全隔離
- ✅ **Transit Gateway**: 實現 VPC 間安全連接
- ✅ **Private Subnets Only**: 所有子網路都是私有的，無公開 IP
- ✅ **憑證認證**: 使用 TLS 憑證進行 VPN 認證
- ✅ **自動憑證管理**: Terraform 自動生成和管理憑證
- ✅ **Split Tunnel**: 僅 VPC 流量走 VPN，優化效能
- ✅ **CloudWatch 日誌**: 完整的連線日誌記錄
- ✅ **高可用性**: 跨多個可用區部署

## 快速開始

```bash
# 1. 部署基礎設施
terraform init
terraform apply

# 2. 下載 VPN 配置
VPN_ENDPOINT_ID=$(terraform output -raw vpn_endpoint_id)
aws ec2 export-client-vpn-client-configuration \
  --client-vpn-endpoint-id $VPN_ENDPOINT_ID \
  --output text > client-vpn-config.ovpn

# 3. 生成客戶端配置
./scripts/create-client-config.sh coco

# 4. 連線
# 使用 AWS VPN Client 或 OpenVPN 匯入 coco-vpn.ovpn
```

詳細步驟請參考 [QUICKSTART.md](QUICKSTART.md)

## 文件

| 文件 | 說明 |
|------|------|
| [QUICKSTART.md](QUICKSTART.md) | 快速開始指南 |
| [ARCHITECTURE.md](ARCHITECTURE.md) | 詳細架構說明 |
| [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) | 完整部署指南 |

## 架構元件

### Network VPC (10.0.0.0/16)
- 用途: Client VPN Endpoint 主機 VPC
- Private Subnets: 10.0.1.0/24, 10.0.2.0/24
- 跨越 ap-northeast-1a 和 ap-northeast-1c

### Business VPC (10.1.0.0/16)
- 用途: 應用服務和資源 VPC
- Private Subnets: 10.1.1.0/24, 10.1.2.0/24
- 未來可部署 Nginx、應用伺服器、資料庫等

### Transit Gateway
- 連接 Network VPC 和 Business VPC
- 自動路由配置
- 支援 VPN 客戶端到 Business VPC 的流量

### Client VPN Endpoint
- 憑證認證方式
- VPN 客戶端 CIDR: 172.16.0.0/22
- UDP 協定，Port 443
- Split Tunnel 模式

## 網路配置

| 資源 | CIDR | 說明 |
|------|------|------|
| Network VPC | 10.0.0.0/16 | VPN 端點 VPC |
| Network Subnet 1 | 10.0.1.0/24 | ap-northeast-1a |
| Network Subnet 2 | 10.0.2.0/24 | ap-northeast-1c |
| Business VPC | 10.1.0.0/16 | 應用服務 VPC |
| Business Subnet 1 | 10.1.1.0/24 | ap-northeast-1a |
| Business Subnet 2 | 10.1.2.0/24 | ap-northeast-1c |
| VPN Clients | 172.16.0.0/22 | VPN 客戶端 IP 池 |

## 預設配置

在 `terraform.tfvars` 中配置:

```hcl
# 區域
aws_region = "ap-northeast-1"

# 客戶端列表
client_names = [
  "coco",
  "client1",
  "client2",
  "admin",
]

# 憑證有效期
certificate_validity_days = 825

# 標籤
tags = {
  Environment = "production"
  Project     = "ClientVPN"
  ManagedBy   = "Terraform"
  Owner       = "SRE Team"
}
```

## 客戶端支援

### macOS
- AWS VPN Client (推薦)
- Tunnelblick (OpenVPN)

### Windows
- AWS VPN Client

### Linux
- OpenVPN CLI
- NetworkManager OpenVPN

## 安全特性

- 🔒 憑證雙向認證
- 🔒 完全加密的 VPN 通道
- 🔒 無公開 IP 的私有網路
- 🔒 Transit Gateway 隔離流量
- 🔒 Security Groups 訪問控制
- 🔒 CloudWatch 日誌審計

## 成本估算

基於 ap-northeast-1 區域（1 個全天候連線）:

| 項目 | 費用 |
|------|------|
| Client VPN Endpoint | ~$108/月 |
| Transit Gateway | ~$50/月 |
| VPN 連線 | ~$36/月 |
| 數據傳輸 | 視使用量 |
| **總計** | **~$194/月** |

## 模組結構

```
.
├── main.tf                      # 主配置
├── variables.tf                 # 變數定義
├── outputs.tf                   # 輸出定義
├── terraform.tfvars             # 變數值
├── modules/
│   ├── vpc/                     # VPC 模組
│   ├── transit-gateway/         # Transit Gateway 模組
│   ├── client-vpn/              # Client VPN 模組
│   └── vpn-certificates/        # 憑證管理模組
├── scripts/
│   └── create-client-config.sh  # 客戶端配置生成腳本
└── generated/                   # 生成的憑證目錄
```

## 使用案例

### 1. 遠端辦公
員工在家或遠端地點安全存取公司內部資源。

### 2. 開發環境存取
開發人員安全存取開發和測試環境。

### 3. 管理員存取
系統管理員安全存取生產環境進行維護。

### 4. 合作夥伴存取
為外部合作夥伴提供受限的臨時存取。

## 擴展計劃

未來可以添加:
- [ ] Nginx Web 伺服器 (在 Business VPC)
- [ ] RDS 資料庫
- [ ] ElastiCache
- [ ] Application Load Balancer
- [ ] Auto Scaling Groups
- [ ] VPC Flow Logs
- [ ] AWS WAF

## 故障排除

### VPN 無法連線
```bash
# 檢查 VPN Endpoint 狀態
aws ec2 describe-client-vpn-endpoints \
  --client-vpn-endpoint-ids $(terraform output -raw vpn_endpoint_id)

# 查看日誌
aws logs tail /aws/clientvpn/main-client-vpn --follow
```

### 憑證問題
```bash
# 驗證憑證
openssl x509 -in generated/clients/coco.crt -noout -dates
openssl verify -CAfile generated/ca.crt generated/clients/coco.crt
```

### 連通性測試
```bash
# 連線後測試
ping 10.0.1.1  # Network VPC
ping 10.1.1.1  # Business VPC (通過 TGW)
```

## 清理資源

```bash
terraform destroy
```

**警告**: 這將刪除所有資源，包括 VPC、Transit Gateway、Client VPN Endpoint 和憑證。

## 前置需求

- Terraform >= 1.0
- AWS CLI 已配置
- 適當的 AWS IAM 權限
- OpenSSL (用於憑證驗證)

## 支援的 AWS 區域

此配置可以在任何支援以下服務的 AWS 區域運行:
- AWS Client VPN
- Transit Gateway
- VPC

預設使用 ap-northeast-1 (東京)。

## 授權

MIT License

## 貢獻

歡迎提交 Issues 和 Pull Requests。

## 參考資料

- [AWS Client VPN Documentation](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/)
- [AWS Transit Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/tgw/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 作者

YuZhiWang - SRE Team

## 版本

- v1.0.0 - 初始版本
  - 雙 VPC 架構
  - Transit Gateway 整合
  - Client VPN with 憑證認證
  - 自動憑證管理
