#!/bin/bash
# create-utility-vm.sh

# ===================================
# スクリプト設定
# ===================================
set -e  # エラー時に即座に終了

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLONE_SCRIPT="${SCRIPT_DIR}/../clone-and-configure-vm.sh"

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
# Utility ノード作成
# ===================================
echo ""
echo "========================================="
echo "=== Utilityノード作成開始 ==="
echo "========================================="

# vessel
echo ""
echo ">>> vessel 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 100 \
    --vm-name "vessel" \
    --target-node "r760xs1" \
    --ip0 "172.16.100.100" \
    --ip1 "172.16.200.100" \
    --cores 16 \
    --memory 128 \
    --disk 128


echo ">>> anchor 作成中..."
"$CLONE_SCRIPT" \
    --template-id "$TEMPLATE_ID" \
    --vm-id 200 \
    --vm-name "anchor" \
    --target-node "r760xs2" \
    --ip0 "172.16.100.200" \
    --ip1 "172.16.200.200" \
    --cores 16 \
    --memory 128 \
    --disk 128


echo ""
echo "✓ 全Utilityノード作成完了"

# ===================================
# 完了メッセージ
# ===================================
echo ""
echo "========================================="
echo "✓ 作成完了"
echo "========================================="
echo ""
echo "=== 作成されたVM一覧 ==="
echo "Utility ノード:"
echo "  - VM 100: vessel (r760xs1) - 172.16.100.100"
echo "  - VM 200: anchor (r760xs2) - 172.16.100.200"
echo ""
echo "=== 次のステップ ==="
echo "1. 全VM起動:"
echo '   ssh r760xs1 "qm start 100"'
echo '   ssh r760xs2 "qm start 200"'
echo ""
echo "2. 起動状態確認:"
echo '   ssh r760xs1 "qm status 100"'
echo '   ssh r760xs2 "qm status 200"'
echo ""
echo "3. SSH接続確認:"
echo "   ssh jaist-lab@172.16.100.100  # vessel"
echo ""
echo "========================================="
