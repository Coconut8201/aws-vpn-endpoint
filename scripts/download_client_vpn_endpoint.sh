#!/bin/bash

# AWS Client VPN Configuration Generator
# 用途: 將基礎 VPN 配置與客戶端憑證整合

# 下載 client VPN Endpoint

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 參數處理
CLIENT_NAME="${1:-client}"
BASE_CONFIG="client-vpn-config.ovpn"
OUTPUT_FILE="${CLIENT_NAME}-vpn.ovpn"

# 檔案路徑
CERT_DIR="certificates/clients"
CLIENT_CERT="${CERT_DIR}/${CLIENT_NAME}.crt"
CLIENT_KEY="${CERT_DIR}/${CLIENT_NAME}.key"

# 檢查基礎配置檔案
if [ ! -f "$BASE_CONFIG" ]; then
    echo -e "${RED}錯誤: 找不到基礎配置檔案: $BASE_CONFIG${NC}"
    echo ""
    echo "請先下載 Client VPN 配置檔案:"
    echo "  1. 使用 AWS Console 下載"
    echo "  2. 或執行以下命令:"
    echo ""
    echo "     VPN_ENDPOINT_ID=\$(terraform output -raw client_vpn_endpoint_id)"
    echo "     AWS_REGION=\$(aws configure get region)"
    echo "     aws ec2 export-client-vpn-client-configuration \\"
    echo "       --client-vpn-endpoint-id \$VPN_ENDPOINT_ID \\"
    echo "       --region \$AWS_REGION \\"
    echo "       --output text > $BASE_CONFIG"
    exit 1
fi

# 檢查客戶端憑證
if [ ! -f "$CLIENT_CERT" ]; then
    echo -e "${RED}錯誤: 找不到客戶端憑證: $CLIENT_CERT${NC}"
    echo ""
    echo "請確認客戶端名稱是否正確，或執行 terraform apply 生成憑證"
    exit 1
fi

# 檢查客戶端私鑰
if [ ! -f "$CLIENT_KEY" ]; then
    echo -e "${RED}錯誤: 找不到客戶端私鑰: $CLIENT_KEY${NC}"
    exit 1
fi

# 檢查輸出檔案是否已存在
if [ -f "$OUTPUT_FILE" ]; then
    echo -e "${YELLOW}警告: 輸出檔案已存在: $OUTPUT_FILE${NC}"
    read -p "是否覆蓋? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "操作已取消"
        exit 0
    fi
fi

echo "配置資訊:"
echo "  客戶端名稱: $CLIENT_NAME"
echo "  基礎配置: $BASE_CONFIG"
echo "  客戶端憑證: $CLIENT_CERT"
echo "  客戶端私鑰: $CLIENT_KEY"
echo "  輸出檔案: $OUTPUT_FILE"
echo ""

echo -n "生成配置檔案... "

# 複製基礎配置
cp "$BASE_CONFIG" "$OUTPUT_FILE"

# 添加憑證
echo "" >> "$OUTPUT_FILE"
echo "<cert>" >> "$OUTPUT_FILE"
cat "$CLIENT_CERT" >> "$OUTPUT_FILE"
echo "</cert>" >> "$OUTPUT_FILE"

# 添加私鑰
echo "" >> "$OUTPUT_FILE"
echo "<key>" >> "$OUTPUT_FILE"
cat "$CLIENT_KEY" >> "$OUTPUT_FILE"
echo "</key>" >> "$OUTPUT_FILE"

echo -e "${GREEN}完成${NC}"
echo ""
echo -e "${GREEN}✓ VPN 配置檔案已生成: $OUTPUT_FILE${NC}"
echo ""
echo "使用方式:"
echo "  1. 將 $OUTPUT_FILE 匯入 OpenVPN 客戶端"
echo "  2. 或使用命令列: openvpn --config $OUTPUT_FILE"
