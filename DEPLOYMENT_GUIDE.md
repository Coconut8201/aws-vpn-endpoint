# AWS Client VPN 部署指南

## 前置需求

1. AWS CLI 已配置
2. Terraform >= 1.0 已安裝
3. 有足夠的 AWS 權限創建以下資源:
   - VPC, Subnets, Route Tables
   - Transit Gateway
   - Client VPN Endpoint
   - ACM Certificates
   - CloudWatch Logs
   - Security Groups

## 部署流程

### 步驟 1: 檢查配置

檢查 `terraform.tfvars` 文件，確認設定符合需求:

```hcl
# AWS 區域
aws_region = "ap-northeast-1"

# VPN 客戶端列表
client_names = [
  "coco",
  "client1",
  "client2",
  "admin",
]

# 其他配置使用預設值
```

### 步驟 2: 初始化 Terraform

```bash
terraform init
```

### 步驟 3: 查看執行計劃

```bash
terraform plan
```

此命令會顯示將要創建的所有資源:
- 2 個 VPC (network-vpc, business-vpc)
- 4 個 Private Subnets
- 1 個 Transit Gateway
- 2 個 TGW VPC Attachments
- 1 個 Client VPN Endpoint
- VPN 授權規則和路由
- CA 和客戶端憑證
- ACM 憑證導入
- CloudWatch Log Group

### 步驟 4: 部署基礎設施

```bash
terraform apply
```

輸入 `yes` 確認部署。

預計部署時間: 10-15 分鐘

### 步驟 5: 查看輸出資訊

部署完成後，查看重要資訊:

```bash
terraform output
```

重要輸出:
- `vpn_endpoint_id`: Client VPN Endpoint ID
- `vpn_endpoint_dns_name`: VPN 端點 DNS 名稱
- `network_vpc_id`: Network VPC ID
- `business_vpc_id`: Business VPC ID
- `transit_gateway_id`: Transit Gateway ID

### 步驟 6: 獲取 VPN 配置檔案

#### 方法 1: 使用 AWS Console

1. 前往 VPC Console
2. 選擇 "Client VPN Endpoints"
3. 選擇您的 VPN Endpoint
4. 點擊 "Download Client Configuration"

#### 方法 2: 使用 AWS CLI

```bash
# 獲取 VPN Endpoint ID
VPN_ENDPOINT_ID=$(terraform output -raw vpn_endpoint_id)

# 下載配置
aws ec2 export-client-vpn-client-configuration \
  --client-vpn-endpoint-id $VPN_ENDPOINT_ID \
  --output text > client-vpn-config.ovpn
```

### 步驟 7: 整合客戶端憑證

為每個客戶端創建完整的 VPN 配置:

```bash
# 設定客戶端名稱
CLIENT_NAME="coco"

# 複製基礎配置
cp client-vpn-config.ovpn ${CLIENT_NAME}-vpn.ovpn

# 添加憑證和金鑰
echo "" >> ${CLIENT_NAME}-vpn.ovpn
echo "<cert>" >> ${CLIENT_NAME}-vpn.ovpn
cat generated/clients/${CLIENT_NAME}.crt >> ${CLIENT_NAME}-vpn.ovpn
echo "</cert>" >> ${CLIENT_NAME}-vpn.ovpn

echo "<key>" >> ${CLIENT_NAME}-vpn.ovpn
cat generated/clients/${CLIENT_NAME}.key >> ${CLIENT_NAME}-vpn.ovpn
echo "</key>" >> ${CLIENT_NAME}-vpn.ovpn
```

或使用提供的腳本（如果有）:

```bash
./scripts/create-client-config.sh coco
```

## 客戶端連線指南

### macOS

#### 選項 1: AWS VPN Client (推薦)

1. 下載 [AWS VPN Client](https://aws.amazon.com/vpn/client-vpn-download/)
2. 安裝應用程式
3. 開啟 AWS VPN Client
4. 點擊 "File" → "Manage Profiles"
5. 點擊 "Add Profile"
6. 輸入 Display Name 並選擇 VPN 配置檔案
7. 點擊 "Connect"

#### 選項 2: OpenVPN (Tunnelblick)

1. 安裝 [Tunnelblick](https://tunnelblick.net/)
2. 雙擊 `.ovpn` 配置檔案
3. 選擇 "Install for This User"
4. 從選單列連線

### Windows

1. 下載 [AWS VPN Client](https://aws.amazon.com/vpn/client-vpn-download/)
2. 安裝應用程式
3. 開啟 AWS VPN Client
4. 點擊 "File" → "Manage Profiles"
5. 點擊 "Add Profile"
6. 輸入 Display Name 並選擇 VPN 配置檔案
7. 點擊 "Connect"

### Linux

使用 OpenVPN CLI:

```bash
sudo openvpn --config coco-vpn.ovpn
```

或安裝 NetworkManager OpenVPN plugin:

```bash
# Ubuntu/Debian
sudo apt-get install network-manager-openvpn network-manager-openvpn-gnome

# 然後從 NetworkManager 匯入配置
```

## 驗證連線

### 1. 檢查 VPN 狀態

連線成功後，客戶端應顯示已連線狀態。

### 2. 檢查 IP 路由

```bash
# macOS/Linux
ip route | grep 10.0.0.0
ip route | grep 10.1.0.0

# Windows
route print
```

應該看到指向 VPN 的路由。

### 3. 測試連線到 VPC

```bash
# Ping Business VPC 的子網路
ping 10.1.1.1

# Ping Network VPC 的子網路
ping 10.0.1.1
```

### 4. 檢查 CloudWatch Logs

在 AWS Console 查看 CloudWatch Logs:

```
Log Group: /aws/clientvpn/main-client-vpn
```

應該看到連線日誌。

## 故障排除

### 無法連線

1. 檢查 VPN Endpoint 狀態:
```bash
aws ec2 describe-client-vpn-endpoints --client-vpn-endpoint-ids $VPN_ENDPOINT_ID
```

2. 確認網路關聯:
```bash
aws ec2 describe-client-vpn-target-networks --client-vpn-endpoint-id $VPN_ENDPOINT_ID
```

3. 檢查授權規則:
```bash
aws ec2 describe-client-vpn-authorization-rules --client-vpn-endpoint-id $VPN_ENDPOINT_ID
```

### 憑證錯誤

確認憑證格式正確且未過期:

```bash
# 檢查憑證有效期
openssl x509 -in generated/clients/coco.crt -noout -dates

# 檢查憑證鏈
openssl verify -CAfile generated/ca.crt generated/clients/coco.crt
```

### 無法存取 Business VPC

1. 檢查 Transit Gateway 路由:
```bash
aws ec2 describe-transit-gateway-route-tables
```

2. 確認 VPN 路由配置:
```bash
aws ec2 describe-client-vpn-routes --client-vpn-endpoint-id $VPN_ENDPOINT_ID
```

3. 檢查 Security Groups

## 架構擴展

### 添加新的客戶端

1. 更新 `terraform.tfvars`:
```hcl
client_names = [
  "coco",
  "client1",
  "client2",
  "admin",
  "new-user",  # 新增
]
```

2. 重新部署:
```bash
terraform apply
```

3. 為新用戶創建 VPN 配置檔案

### 在 Business VPC 部署服務

未來可以在 Business VPC 的 private subnets 部署:
- EC2 instances (Web servers, App servers)
- RDS databases
- ElastiCache
- Other AWS services

所有這些服務都可以通過 VPN 安全存取，無需公開 IP。

## 清理資源

警告: 這將刪除所有創建的資源

```bash
terraform destroy
```

輸入 `yes` 確認刪除。

**注意事項**:
- Transit Gateway 可能需要幾分鐘才能完全刪除
- 確保沒有活動的 VPN 連線
- CloudWatch Logs 將被保留（除非手動刪除）

## 成本估算

以 ap-northeast-1 區域為例（2024年價格）:

### 固定成本（每小時）
- Client VPN Endpoint: ~$0.15/小時
- Transit Gateway: ~$0.07/小時

### 使用成本
- Client VPN 連線: ~$0.05/小時/連線
- Transit Gateway 數據傳輸: ~$0.02/GB

### 月度估算（1個連線，24/7）
- VPN Endpoint: ~$108/月
- Transit Gateway: ~$50/月
- VPN 連線: ~$36/月
- 數據傳輸: 視使用量而定

**總計**: 約 $194/月 + 數據傳輸費用

## 安全建議

1. 定期輪換客戶端憑證
2. 監控 CloudWatch Logs 異常活動
3. 使用 AWS CloudTrail 追蹤 API 調用
4. 實施最小權限原則
5. 定期審查授權規則
6. 啟用 MFA（如果可能）
7. 限制 VPN 存取時間（使用 Lambda 自動化）

## 支援

遇到問題請參考:
- [AWS Client VPN 文件](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/)
- [Terraform AWS Provider 文件](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
