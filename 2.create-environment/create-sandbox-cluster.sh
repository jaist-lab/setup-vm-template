#!/bin/bash
# create-sandbox-cluster.sh - Sandbox環境のKubernetesクラスタを作成

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
ENVIRONMENT="Sandbox"

echo "========================================"
echo "Sandbox環境 Kubernetesクラスタ作成"
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

# Sandbox-Master01
echo ""
echo ">>> Sandbox-Master01 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 131 \
    --vm-name "sandbox-master01" \
    --target-node "r760xs1" \
    --ip0 "172.16.100.131" \
    --ip1 "172.16.200.131" \
    --cores 4 \
    --memory 32 \
    --disk 64 \
    --etcd-disk 16

# Sandbox-Master02
echo ""
echo ">>> Sandbox-Master02 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 132 \
    --vm-name "sandbox-master02" \
    --target-node "r760xs2" \
    --ip0 "172.16.100.132" \
    --ip1 "172.16.200.132" \
    --cores 4 \
    --memory 32 \
    --disk 64 \
    --etcd-disk 16

# Sandbox-Master03
echo ""
echo ">>> Sandbox-Master03 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 133 \
    --vm-name "sandbox-master03" \
    --target-node "r760xs3" \
    --ip0 "172.16.100.133" \
    --ip1 "172.16.200.133" \
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

# Sandbox-Node01
echo ""
echo ">>> Sandbox-Node01 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 134 \
    --vm-name "sandbox-node01" \
    --target-node "r760xs4" \
    --ip0 "172.16.100.134" \
    --ip1 "172.16.200.134" \
    --cores 8 \
    --memory 32 \
    --disk 64

# Sandbox-Node02
echo ""
echo ">>> Sandbox-Node02 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 135 \
    --vm-name "sandbox-node02" \
    --target-node "r760xs5" \
    --ip0 "172.16.100.135" \
    --ip1 "172.16.200.135" \
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
echo "✓ Sandbox環境クラスタ作成完了"
echo "========================================="
echo ""
echo "=== 作成されたVM一覧 ==="
echo "Master ノード:"
echo "  - VM 131: sandbox-master01 (r760xs1) - 172.16.100.131"
echo "  - VM 132: sandbox-master02 (r760xs2) - 172.16.100.132"
echo "  - VM 133: sandbox-master03 (r760xs3) - 172.16.100.133"
echo ""
echo "Worker ノード:"
echo "  - VM 134: sandbox-node01 (r760xs4) - 172.16.100.134"
echo "  - VM 135: sandbox-node02 (r760xs5) - 172.16.100.135"
echo ""
echo "=== 次のステップ ==="
echo "1. 全VM起動:"
echo "   for vmid in 131 132 133 134 135; do qm start \$vmid; done"
echo ""
echo "2. 起動状態確認:"
echo "   for vmid in 131 132 133 134 135; do echo \"VM \$vmid:\"; qm status \$vmid; done"
echo ""
echo "3. SSH接続確認:"
echo "   ssh jaist-lab@172.16.100.131  # sandbox-master01"
echo ""
echo "4. etcdディスク確認 (Masterノードのみ):"
echo "   ssh jaist-lab@172.16.100.131 'df -h | grep etcd'"
echo "   ssh jaist-lab@172.16.100.131 'sudo journalctl -u setup-etcd-disk.service'"
echo ""
echo "========================================="
