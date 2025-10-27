#!/bin/bash

echo "========================================="
echo "全ノードのCeph設定確認・修正"
echo "========================================="

NODES=("172.16.100.12" "172.16.100.13" "172.16.100.14" "172.16.100.15")

for node_ip in "${NODES[@]}"; do
    echo ""
    echo "=== ノード: $node_ip ==="
    
    # /etc/cephディレクトリを作成
    ssh root@$node_ip "mkdir -p /etc/ceph"
    
    # ceph.confをコピー
    echo "  ceph.conf をコピー中..."
    scp /etc/pve/ceph.conf root@$node_ip:/etc/ceph/
    
    # keyringをコピー
    echo "  keyring をコピー中..."
    scp /etc/pve/priv/ceph.client.admin.keyring root@$node_ip:/etc/ceph/
    
    # 権限設定
    ssh root@$node_ip "chmod 600 /etc/ceph/ceph.client.admin.keyring"
    
    # 確認
    echo "  接続テスト..."
    ssh root@$node_ip "ceph -s | head -5"
done

echo ""
echo "========================================="
echo "✓ Ceph設定完了"
echo "========================================="