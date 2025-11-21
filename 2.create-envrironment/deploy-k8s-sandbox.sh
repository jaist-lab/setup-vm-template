#!/bin/bash
# deploy-k8s-sandbox.sh - sandbox Kubernetes環境一括作成

set -e

SCRIPT_DIR=$(dirname "$0")

echo "========================================="
echo "Sandbox Kubernetes環境作成"
echo "========================================="
echo ""

# Master ノード作成
echo "=== Master ノード作成 ==="
$SCRIPT_DIR/create-k8s-master.sh 902 131 dev-master01 r760xs3 172.16.100.131 16
$SCRIPT_DIR/create-k8s-master.sh 902 132 dev-master02 r760xs4 172.16.100.132 16
$SCRIPT_DIR/create-k8s-master.sh 902 133 dev-master03 r760xs5 172.16.100.133 16

echo ""
echo "=== Worker ノード作成 ==="
$SCRIPT_DIR/create-k8s-worker.sh 902 134 dev-node01 r760xs4 172.16.100.134 4 32
$SCRIPT_DIR/create-k8s-worker.sh 902 135 dev-node02 r760xs5 172.16.100.135 4 32

echo ""
echo "========================================="
echo "✓ Sandbox 環境作成完了"
echo "========================================="
echo ""
echo "VM一覧:"
echo "  Master: 131 (dev-master01), 132 (dev-master02), 133 (dev-master03)"
echo "  Worker: 134 (dev-node01), 135 (dev-node02)"
echo ""
echo "起動コマンド:"
echo "  qm start 131 && qm start 132 && qm start 133"
echo "  qm start 134 && qm start 135"
