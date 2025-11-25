#!/bin/bash
# create-development-cluster.sh - Development環境のKubernetesクラスタを作成

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
ENVIRONMENT="Development"

echo "========================================"
echo "Development環境 Kubernetesクラスタ作成"
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

# Dev-Master01
echo ""
echo ">>> Dev-Master01 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 121 \
    --vm-name "dev-master01" \
    --target-node "r760xs1" \
    --ip0 "172.16.100.121" \
    --ip1 "172.16.200.121" \
    --cores 4 \
    --memory 32 \
    --disk 64 \
    --etcd-disk 16

# Dev-Master02
echo ""
echo ">>> Dev-Master02 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 122 \
    --vm-name "dev-master02" \
    --target-node "r760xs2" \
    --ip0 "172.16.100.122" \
    --ip1 "172.16.200.122" \
    --cores 4 \
    --memory 32 \
    --disk 64 \
    --etcd-disk 16

# Dev-Master03
echo ""
echo ">>> Dev-Master03 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 123 \
    --vm-name "dev-master03" \
    --target-node "r760xs3" \
    --ip0 "172.16.100.123" \
    --ip1 "172.16.200.123" \
    --cores 4 \
    --memory 32 \
    --disk 64 \
    --etcd-disk 16

echo ""
echo "✓ 全Masterノード作成完了"

# ===================================
# Worker ノード作成
# ===================================
echo ""
echo "========================================="
echo "=== Workerノード作成開始 ==="
echo "========================================="

# Dev-Node01
echo ""
echo ">>> Dev-Node01 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 124 \
    --vm-name "dev-node01" \
    --target-node "r760xs4" \
    --ip0 "172.16.100.124" \
    --ip1 "172.16.200.124" \
    --cores 8 \
    --memory 32 \
    --disk 64

# Dev-Node02
echo ""
echo ">>> Dev-Node02 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 125 \
    --vm-name "dev-node02" \
    --target-node "r760xs5" \
    --ip0 "172.16.100.125" \
    --ip1 "172.16.200.125" \
    --cores 8 \
    --memory 32 \
    --disk 64

echo ""
echo "✓ 全Workerノード作成完了"

# ===================================
# 完了メッセージ
# ===================================
echo ""
echo "========================================="
echo "✓ Development環境クラスタ作成完了"
echo "========================================="
echo ""
echo "=== 作成されたVM一覧 ==="
echo "Master ノード:"
echo "  - VM 121: dev-master01 (r760xs1) - 172.16.100.121"
echo "  - VM 122: dev-master02 (r760xs2) - 172.16.100.122"
echo "  - VM 123: dev-master03 (r760xs3) - 172.16.100.123"
echo ""
echo "Worker ノード:"
echo "  - VM 124: dev-node01 (r760xs4) - 172.16.100.124"
echo "  - VM 125: dev-node02 (r760xs5) - 172.16.100.125"
echo ""
echo "=== 次のステップ ==="
echo "1. 全VM起動:"
echo "   for vmid in 121 122 123 124 125; do qm start \$vmid; done"
echo ""
echo "2. 起動状態確認:"
echo "   for vmid in 121 122 123 124 125; do echo \"VM \$vmid:\"; qm status \$vmid; done"
echo ""
echo "3. SSH接続確認:"
echo "   ssh jaist-lab@172.16.100.121  # dev-master01"
echo ""
echo "4. etcdディスク確認 (Masterノードのみ):"
echo "   ssh jaist-lab@172.16.100.121 'df -h | grep etcd'"
echo "   ssh jaist-lab@172.16.100.121 'sudo journalctl -u setup-etcd-disk.service'"
echo ""
echo "========================================="
