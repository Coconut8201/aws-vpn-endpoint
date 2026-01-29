#!/bin/bash
# 設定 client VPN config

set -e  # 任何命令失敗就停止

VPN_ENDPOINT_ID=$(terraform output -raw client_vpn_endpoint_id)
AWS_REGION=$(aws configure get region)

if [ -z "$VPN_ENDPOINT_ID" ] || [ -z "$AWS_REGION" ]; then
  echo "Error: VPN_ENDPOINT_ID 或 AWS_REGION 為空"
  exit 1
fi

aws ec2 export-client-vpn-client-configuration \
  --client-vpn-endpoint-id "$VPN_ENDPOINT_ID" \
  --region "$AWS_REGION" \
  --output text > client-vpn-config.ovpn

echo "VPN 設定檔已生成: client-vpn-config.ovpn"
