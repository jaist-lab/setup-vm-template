#!/bin/bash
# deploy-k8s-production.sh - Production Kubernetes環境一括作成

set -e

SCRIPT_DIR=$(dirname "$0")

echo "========================================="
echo "Production Kubernetes環境作成"
echo "========================================="
echo ""

# Master ノード作成
echo "=== Master ノード作成 ==="
$SCRIPT_DIR/create-k8s-master.sh 900 101 master01 r760xs3 172.16.100.101 32
$SCRIPT_DIR/create-k8s-master.sh 900 102 master02 r760xs4 172.16.100.102 32
$SCRIPT_DIR/create-k8s-master.sh 900 103 master03 r760xs5 172.16.100.103 32

echo ""
echo "=== Worker ノード作成 ==="
$SCRIPT_DIR/create-k8s-worker.sh 900 104 node01 r760xs4 172.16.100.104 16 128
$SCRIPT_DIR/create-k8s-worker.sh 900 105 node02 r760xs5 172.16.100.105 16 128

echo ""
echo "========================================="
echo "✓ Production環境作成完了"
echo "========================================="
echo ""
echo "VM一覧:"
echo "  Master: 101 (master01), 102 (master02), 103 (master03)"
echo "  Worker: 104 (node01), 105 (node02)"
echo ""
echo "起動コマンド:"
echo "  qm start 101 && qm start 102 && qm start 103"
echo "  qm start 104 && qm start 105"
