#!/bin/bash
# deploy-k8s-development.sh - Development Kubernetes環境一括作成

set -e

SCRIPT_DIR=$(dirname "$0")

echo "========================================="
echo "Development Kubernetes環境作成"
echo "========================================="
echo ""

# Master ノード作成
echo "=== Master ノード作成 ==="
$SCRIPT_DIR/create-k8s-master.sh 900 121 dev-master01 r760xs3 172.16.100.121 16
$SCRIPT_DIR/create-k8s-master.sh 900 122 dev-master02 r760xs4 172.16.100.122 16
$SCRIPT_DIR/create-k8s-master.sh 900 123 dev-master03 r760xs5 172.16.100.123 16

echo ""
echo "=== Worker ノード作成 ==="
$SCRIPT_DIR/create-k8s-worker.sh 900 124 dev-node01 r760xs4 172.16.100.124 4 32
$SCRIPT_DIR/create-k8s-worker.sh 900 125 dev-node02 r760xs5 172.16.100.125 4 32

echo ""
echo "========================================="
echo "✓ Development環境作成完了"
echo "========================================="
echo ""
echo "VM一覧:"
echo "  Master: 121 (dev-master01), 122 (dev-master02), 123 (dev-master03)"
echo "  Worker: 124 (dev-node01), 125 (dev-node02)"
echo ""
echo "起動コマンド:"
echo "  qm start 121 && qm start 122 && qm start 123"
echo "  qm start 124 && qm start 125"
