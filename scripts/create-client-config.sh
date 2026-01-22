#!/bin/bash

# AWS Client VPN Configuration Generator
# 用途: 將基礎 VPN 配置與客戶端憑證整合

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 顯示使用方法
usage() {
    echo "Usage: $0 <client-name> [base-config-file]"
    echo ""
    echo "Arguments:"
    echo "  client-name        客戶端名稱 (例如: coco, client1)"
    echo "  base-config-file   基礎 VPN 配置檔案 (選填，預設: client-vpn-config.ovpn)"
    echo ""
    echo "Example:"
    echo "  $0 coco"
    echo "  $0 client1 downloaded-vpn-config.ovpn"
    exit 1
}

# 檢查參數
if [ $# -lt 1 ]; then
    usage
fi

CLIENT_NAME=$1
BASE_CONFIG=${2:-"client-vpn-config.ovpn"}
OUTPUT_FILE="${CLIENT_NAME}-vpn.ovpn"

# 檔案路徑
CERT_DIR="generated/clients"
CLIENT_CERT="${CERT_DIR}/${CLIENT_NAME}.crt"
CLIENT_KEY="${CERT_DIR}/${CLIENT_NAME}.key"

echo -e "${GREEN}AWS Client VPN 配置生成器${NC}"
echo "=================================="
echo ""

# 檢查基礎配置檔案
if [ ! -f "$BASE_CONFIG" ]; then
    echo -e "${RED}錯誤: 找不到基礎配置檔案: $BASE_CONFIG${NC}"
    echo ""
    echo "請先下載 Client VPN 配置檔案:"
    echo "  1. 使用 AWS Console 下載"
    echo "  2. 或執行以下命令:"
    echo ""
    echo "     VPN_ENDPOINT_ID=\$(terraform output -raw vpn_endpoint_id)"
    echo "     aws ec2 export-client-vpn-client-configuration \\"
    echo "       --client-vpn-endpoint-id \$VPN_ENDPOINT_ID \\"
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

echo "配置資訊:"
echo "  客戶端名稱: $CLIENT_NAME"
echo "  基礎配置: $BASE_CONFIG"
echo "  客戶端憑證: $CLIENT_CERT"
echo "  客戶端私鑰: $CLIENT_KEY"
echo "  輸出檔案: $OUTPUT_FILE"
echo ""

# 創建配置檔案
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

# 驗證憑證
echo -n "驗證憑證有效期... "
CERT_EXPIRY=$(openssl x509 -in "$CLIENT_CERT" -noout -enddate | cut -d= -f2)
echo -e "${GREEN}有效${NC}"
echo "  到期日期: $CERT_EXPIRY"
echo ""

# 顯示配置檔案資訊
echo -e "${GREEN}配置檔案生成成功!${NC}"
echo ""
echo "配置檔案: $OUTPUT_FILE"
echo ""
echo "下一步:"
echo "  1. 將 $OUTPUT_FILE 傳送給客戶端使用者"
echo "  2. 使用 AWS VPN Client 或 OpenVPN 匯入配置"
echo ""
echo "連線測試:"
echo "  macOS/Linux: sudo openvpn --config $OUTPUT_FILE"
echo "  或使用 AWS VPN Client GUI"
echo ""

# 顯示安全提醒
echo -e "${YELLOW}安全提醒:${NC}"
echo "  - 此檔案包含私鑰，請妥善保管"
echo "  - 不要透過不安全的管道傳送"
echo "  - 建議使用加密方式傳送給使用者"
echo ""
