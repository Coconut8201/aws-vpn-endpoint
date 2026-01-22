# 快速開始指南

## 一鍵部署

```bash
# 1. 初始化
terraform init

# 2. 部署
terraform apply -auto-approve
```

等待 10-15 分鐘完成部署。

## 獲取 VPN 配置

### 步驟 1: 下載基礎配置

```bash
# 獲取 VPN Endpoint ID
VPN_ENDPOINT_ID=$(terraform output -raw vpn_endpoint_id)

# 下載配置檔案
aws ec2 export-client-vpn-client-configuration \
  --client-vpn-endpoint-id $VPN_ENDPOINT_ID \
  --output text > client-vpn-config.ovpn
```

### 步驟 2: 生成客戶端配置

```bash
# 為 coco 用戶生成完整配置
./scripts/create-client-config.sh coco

# 為其他用戶生成配置
./scripts/create-client-config.sh client1
./scripts/create-client-config.sh client2
./scripts/create-client-config.sh admin
```

### 步驟 3: 連線測試

使用 AWS VPN Client 或 OpenVPN 連線:

```bash
# macOS/Linux (需要 sudo)
sudo openvpn --config coco-vpn.ovpn
```

## 架構驗證

連線成功後測試連通性:

```bash
# Ping Network VPC
ping 10.0.1.1

# Ping Business VPC (透過 Transit Gateway)
ping 10.1.1.1
```

## 部署的資源

- ✅ Network VPC (10.0.0.0/16) - 2 個 private subnets
- ✅ Business VPC (10.1.0.0/16) - 2 個 private subnets
- ✅ Transit Gateway - 連接兩個 VPC
- ✅ Client VPN Endpoint - 憑證認證
- ✅ 4 個客戶端憑證 (coco, client1, client2, admin)
- ✅ CloudWatch Logs - VPN 連線日誌

## 查看資源

```bash
# 查看所有輸出
terraform output

# 查看 VPN Endpoint
terraform output vpn_endpoint_id
terraform output vpn_endpoint_dns_name

# 查看 VPC 資訊
terraform output network_vpc_id
terraform output business_vpc_id

# 查看 Transit Gateway
terraform output transit_gateway_id
```

## 重要檔案位置

```
generated/
├── ca.crt                    # CA 憑證
├── ca.key                    # CA 私鑰
├── server.crt                # 伺服器憑證
├── server.key                # 伺服器私鑰
└── clients/
    ├── coco.crt              # 客戶端憑證
    ├── coco.key              # 客戶端私鑰
    ├── client1.crt
    ├── client1.key
    ├── client2.crt
    ├── client2.key
    ├── admin.crt
    └── admin.key
```

## 清理

```bash
terraform destroy -auto-approve
```

## 下一步

詳細資訊請參考:
- [ARCHITECTURE.md](ARCHITECTURE.md) - 架構說明
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - 完整部署指南

## 故障排除

### 連線失敗

1. 檢查 VPN Endpoint 狀態:
```bash
aws ec2 describe-client-vpn-endpoints \
  --client-vpn-endpoint-ids $(terraform output -raw vpn_endpoint_id)
```

2. 查看連線日誌:
```bash
aws logs tail /aws/clientvpn/main-client-vpn --follow
```

### 憑證問題

驗證憑證:
```bash
# 檢查憑證有效期
openssl x509 -in generated/clients/coco.crt -noout -dates

# 驗證憑證鏈
openssl verify -CAfile generated/ca.crt generated/clients/coco.crt
```

## 預估成本

約 $194/月 + 數據傳輸費用 (基於 1 個全天候連線)

詳細成本分析請參考 [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)。
