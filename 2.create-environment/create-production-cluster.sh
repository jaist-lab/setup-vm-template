#!/bin/bash
# create-production-cluster.sh - Production環境のKubernetesクラスタを作成

# ===================================
# スクリプト設定
# ===================================
set -e  # エラー時に即座に終了

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLONE_SCRIPT="${SCRIPT_DIR}/clone-and-configure-vm.sh"

# 共通スクリプトの存在確認
if [ ! -f "$CLONE_SCRIPT" ]; then
    echo "エラー: clone-and-configure-vm.sh が見つかりません" >&2
    echo "パス: $CLONE_SCRIPT" >&2
    exit 1
fi

# ===================================
# 環境設定
# ===================================
TEMPLATE_ID=900
ENVIRONMENT="Production"

echo "========================================"
echo "Production環境 Kubernetesクラスタ作成"
echo "========================================"
echo "テンプレートID: $TEMPLATE_ID"
echo "環境: $ENVIRONMENT"
echo ""

# ===================================
# Master ノード作成
# ===================================
echo ""
echo "========================================="
echo "=== Masterノード作成開始 ==="
echo "========================================="

# Master01
echo ""
echo ">>> Master01 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 101 \
    --vm-name "master01" \
    --target-node "r760xs1" \
    --ip0 "172.16.100.101" \
    --ip1 "172.16.200.101" \
    --cores 8 \
    --memory 64 \
    --disk 64 \
    --etcd-disk 32

# Master02
echo ""
echo ">>> Master02 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 102 \
    --vm-name "master02" \
    --target-node "r760xs2" \
    --ip0 "172.16.100.102" \
    --ip1 "172.16.200.102" \
    --cores 8 \
    --memory 64 \
    --disk 64 \
    --etcd-disk 32

# Master03
echo ""
echo ">>> Master03 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 103 \
    --vm-name "master03" \
    --target-node "r760xs3" \
    --ip0 "172.16.100.103" \
    --ip1 "172.16.200.103" \
    --cores 8 \
    --memory 64 \
    --disk 64 \
    --etcd-disk 32

echo ""
echo "✓ 全Masterノード作成完了"

# ===================================
# Worker ノード作成
# ===================================
echo ""
echo "========================================="
echo "=== Workerノード作成開始 ==="
echo "========================================="

# Node01
echo ""
echo ">>> Node01 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 104 \
    --vm-name "node01" \
    --target-node "r760xs4" \
    --ip0 "172.16.100.104" \
    --ip1 "172.16.200.104" \
    --cores 16 \
    --memory 128 \
    --disk 128

# Node02
echo ""
echo ">>> Node02 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 105 \
    --vm-name "node02" \
    --target-node "r760xs5" \
    --ip0 "172.16.100.105" \
    --ip1 "172.16.200.105" \
    --cores 16 \
    --memory 128 \
    --disk 128

echo ""
echo "✓ 全Workerノード作成完了"

# ===================================
# 完了メッセージ
# ===================================
echo ""
echo "========================================="
echo "✓ Production環境クラスタ作成完了"
echo "========================================="
echo ""
echo "=== 作成されたVM一覧 ==="
echo "Master ノード:"
echo "  - VM 101: master01 (r760xs1) - 172.16.100.101"
echo "  - VM 102: master02 (r760xs2) - 172.16.100.102"
echo "  - VM 103: master03 (r760xs3) - 172.16.100.103"
echo ""
echo "Worker ノード:"
echo "  - VM 104: node01 (r760xs4) - 172.16.100.104"
echo "  - VM 105: node02 (r760xs5) - 172.16.100.105"
echo ""
echo "=== 次のステップ ==="
echo "1. 全VM起動:"
echo "   for vmid in 101 102 103 104 105; do qm start \$vmid; done"
echo ""
echo "2. 起動状態確認:"
echo "   for vmid in 101 102 103 104 105; do echo \"VM \$vmid:\"; qm status \$vmid; done"
echo ""
echo "3. SSH接続確認:"
echo "   ssh jaist-lab@172.16.100.101  # master01"
echo ""
echo "4. etcdディスク確認 (Masterノードのみ):"
echo "   ssh jaist-lab@172.16.100.101 'df -h | grep etcd'"
echo "   ssh jaist-lab@172.16.100.101 'sudo journalctl -u setup-etcd-disk.service'"
echo ""
echo "========================================="
