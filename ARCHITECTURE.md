# AWS Client VPN 架構說明

## 架構概覽

此架構實現了安全的遠端存取解決方案，使用 AWS Client VPN、Transit Gateway 和雙 VPC 設計。

```
┌─────────────────────────────────────────────────────────────────┐
│                         遠端使用者                                 │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ↓
              ┌────────────────────────┐
              │   Client VPN Endpoint  │
              │   (Certificate Auth)    │
              └────────────┬───────────┘
                           │
┌──────────────────────────┼──────────────────────────────────────┐
│  Network VPC (10.0.0.0/16)                                      │
│                          │                                       │
│  ┌───────────────────────┴──────────────────────┐              │
│  │  Private Subnets (no public IP)              │              │
│  │  - 10.0.1.0/24 (ap-northeast-1a)            │              │
│  │  - 10.0.2.0/24 (ap-northeast-1c)            │              │
│  └──────────────────────┬───────────────────────┘              │
└─────────────────────────┼────────────────────────────────────────┘
                          │
                          ↓
              ┌────────────────────────┐
              │   Transit Gateway      │
              │   (VPC 連接中樞)        │
              └────────────┬───────────┘
                          │
                          ↓
┌─────────────────────────┼────────────────────────────────────────┐
│  Business VPC (10.1.0.0/16)                                      │
│                         │                                         │
│  ┌──────────────────────┴──────────────────────┐                │
│  │  Private Subnets (no public IP)             │                │
│  │  - 10.1.1.0/24 (ap-northeast-1a)           │                │
│  │  - 10.1.2.0/24 (ap-northeast-1c)           │                │
│  │                                              │                │
│  │  [應用服務運行位置 - 未來可部署 Nginx]        │                │
│  └──────────────────────────────────────────────┘               │
└──────────────────────────────────────────────────────────────────┘
```

## 架構元件

### 1. Network VPC (10.0.0.0/16)
- **用途**: Client VPN Endpoint 的主機 VPC
- **子網路**: 
  - 10.0.1.0/24 (ap-northeast-1a) - Private
  - 10.0.2.0/24 (ap-northeast-1c) - Private
- **特點**: 所有子網路都是私有的，無 public IP

### 2. Business VPC (10.1.0.0/16)
- **用途**: 應用服務和資源的主機 VPC
- **子網路**:
  - 10.1.1.0/24 (ap-northeast-1a) - Private
  - 10.1.2.0/24 (ap-northeast-1c) - Private
- **特點**: 完全私有網路，未來可部署應用服務（如 Nginx）

### 3. Transit Gateway
- **功能**: 連接 Network VPC 和 Business VPC
- **路由**:
  - Network VPC → Business VPC (10.1.0.0/16)
  - Business VPC → Network VPC (10.0.0.0/16)
  - Business VPC → VPN Clients (172.16.0.0/22)

### 4. Client VPN Endpoint
- **認證方式**: 憑證認證 (Certificate-based)
- **客戶端 CIDR**: 172.16.0.0/22 (約 1024 個 IP)
- **協定**: UDP on port 443
- **Split Tunnel**: 啟用（僅 VPC 流量走 VPN）
- **日誌**: CloudWatch Logs (保留 7 天)

## 網路流量路徑

### VPN 客戶端訪問 Business VPC 資源

```
VPN 客戶端 (172.16.0.x)
    ↓
Client VPN Endpoint
    ↓
Network VPC Private Subnet
    ↓
Transit Gateway
    ↓
Business VPC Private Subnet
    ↓
應用服務
```

## 安全特性

1. **無公開 IP**: 所有子網路都是私有的
2. **憑證認證**: 使用 TLS 憑證進行 VPN 認證
3. **加密通道**: VPN 流量完全加密
4. **Split Tunnel**: 只有目標網路流量走 VPN
5. **Security Groups**: 控制網路訪問

## CIDR 分配

| 用途 | CIDR | 大小 |
|------|------|------|
| Network VPC | 10.0.0.0/16 | 65,536 IPs |
| Network Private Subnet 1 | 10.0.1.0/24 | 256 IPs |
| Network Private Subnet 2 | 10.0.2.0/24 | 256 IPs |
| Business VPC | 10.1.0.0/16 | 65,536 IPs |
| Business Private Subnet 1 | 10.1.1.0/24 | 256 IPs |
| Business Private Subnet 2 | 10.1.2.0/24 | 256 IPs |
| VPN Clients | 172.16.0.0/22 | 1,024 IPs |

## 部署步驟

### 1. 初始化 Terraform
```bash
terraform init
```

### 2. 檢查配置
```bash
terraform plan
```

### 3. 部署基礎設施
```bash
terraform apply
```

### 4. 獲取 VPN 配置檔案

部署完成後，VPN 配置檔案會生成在 `generated/clients/` 目錄。

### 5. 下載 Client VPN 配置

從 AWS Console 下載 Client VPN 配置檔案，或使用 AWS CLI:

```bash
aws ec2 export-client-vpn-client-configuration \
  --client-vpn-endpoint-id <vpn-endpoint-id> \
  --output text > client-vpn-config.ovpn
```

### 6. 整合憑證

將客戶端憑證添加到配置檔案:

```bash
cat generated/clients/<client-name>.crt >> client-vpn-config.ovpn
cat generated/clients/<client-name>.key >> client-vpn-config.ovpn
```

## 客戶端連線

### macOS / Linux
使用 AWS VPN Client 或 OpenVPN:
```bash
sudo openvpn --config client-vpn-config.ovpn
```

### Windows
1. 安裝 AWS VPN Client
2. 匯入配置檔案
3. 連線

## 擴展計劃

未來可以在 Business VPC 中部署:
- Nginx Web 伺服器
- 應用伺服器
- 資料庫
- 其他內部服務

## 成本考量

- **Transit Gateway**: 
  - 每小時費用
  - 數據傳輸費用
- **Client VPN Endpoint**:
  - 每小時費用
  - 每連線費用
- **VPC**:
  - 免費（基本功能）
- **CloudWatch Logs**:
  - 儲存和查詢費用

## 清理資源

```bash
terraform destroy
```

**注意**: 刪除 Transit Gateway 和 Client VPN Endpoint 可能需要幾分鐘時間。
