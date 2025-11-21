#!/bin/bash
# ubuntu-2404-development-template VM 作成スクリプト
# ubuntu-2404-baseを複製して作成します。
#--------------------------------------------
# 全て手動で作成する場合は以下のコマンドを使用してください
#--------------------------------------------
# Proxmox VE 用
# ProductionテンプレートVM作成スクリプト
#./create-vm.sh \
#    --vm-id  901 \
#    --name   "ubuntu-2404-production" \
#    --cores  8 \
#    --memory 128 \
#    --etcd-disk 32 \
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

# VM 901: Production Template
echo -e "${GREEN} VM 901 (Production Template) を作成中...${NC}"
qm clone $BASE_VMID 901 --name ubuntu-2404-production-template --full

# VMが作成されるまで少し待機
sleep 10

# CPU、メモリ、ディスク設定を変更
echo "  - CPUコア数を8に設定"
qm set 901 --cores 8

echo "  - メモリを128GBに設定"
qm set 901 --memory 131072

echo "  - ディスクを64GBに拡張"
qm resize 901 scsi0 64G

echo "  - etcd NVMeディスクを32GBに拡張"
qm resize 901 scsi1 32G

echo -e "${GREEN}✓ VM 901 作成完了${NC}"
echo ""


# 作成されたVMの確認
echo -e "${BLUE}=== 作成されたVMの設定確認 ===${NC}"
echo ""
echo "--- VM 901 (Production) ---"
qm config 901 | grep -E "name:|cores:|memory:|scsi0:"
echo ""


echo -e "${GREEN}=== すべての処理が完了しました ===${NC}"
echo -e "${GREEN}=== このVMにCloud-initの設定を行ってください ===${NC}"
