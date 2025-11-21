#!/bin/bash
# ubuntu-2404-development-template VM 作成スクリプト  
# ubuntu-2404-baseを複製して作成します。
#--------------------------------------------
# 全て手動で作成する場合は以下のコマンドを使用してください
#--------------------------------------------
# Proxmox VE 用
# DevelopmentテンプレートVM作成スクリプト
# ./create-vm.sh \
#    --vm-id  902 \
#    --name   "ubuntu-2404-development" \
#    --cores  2 \
#    --memory 32 \
#    --etcd-disk 16 \
#    --disk   64
#--------------------------------------------

# ベースVM ID
BASE_VMID=900

# カラー出力用
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Proxmox VM クローン作成スクリプト ===${NC}"
echo ""

# VM 902: Development Template
echo -e "${GREEN} VM 902 (Development Template) を作成中...${NC}"
qm clone $BASE_VMID 902 --name ubuntu-2404-development-template --full

# VMが作成されるまで少し待機
sleep 10

# CPU、メモリ、ディスク設定を変更
echo "  - CPUコア数を2に設定"
qm set 902 --cores 2

echo "  - メモリを32GBに設定"
qm set 902 --memory 32768

echo "  - ディスクを64GBに拡張"
qm resize 902 scsi0 64G

echo -e "${GREEN}✓ VM 902 作成完了${NC}"
echo ""

# 作成されたVMの確認
echo -e "${BLUE}=== 作成されたVMの設定確認 ===${NC}"
echo ""
echo "--- VM 902 (Development) ---"
qm config 902 | grep -E "name:|cores:|memory:|scsi0:"
echo ""

echo -e "${GREEN}=== すべての処理が完了しました ===${NC}"
echo -e "${GREEN}=== このVMにCloud-initの設定を行ってください ===${NC}"
