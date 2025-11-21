#!/bin/bash
# create-k8s-worker.sh - Kubernetes Worker VM作成スクリプト
# テンプレートからクローン（etcdディスクなし）

set -e

# 引数
TEMPLATE_ID=${1:-901}
VM_ID=$2
VM_NAME=$3
TARGET_NODE=$4
IP_ADDRESS=$5
CPU_CORES=${6:-16}
MEMORY_GB=${7:-128}

# 使用方法
usage() {
    cat << EOF
使用方法: $0 <TEMPLATE_ID> <VM_ID> <VM_NAME> <TARGET_NODE> <IP_ADDRESS> [CPU_CORES] [MEMORY_GB]

例:
  Production Worker:
    $0 901 120 node01 r760xs4 172.16.200.111 16 128
    $0 901 121 node02 r760xs5 172.16.200.112 16 128

  Development Worker:
    $0 902 131 dev-node01 r760xs4 172.16.200.131 4 32
    $0 902 132 dev-node02 r760xs5 172.16.200.132 4 32

引数:
  TEMPLATE_ID  : テンプレートVM ID (901=Production, 902=Development)
  VM_ID        : 作成するVM ID
  VM_NAME      : VM名
  TARGET_NODE  : 配置先ノード (r760xs1-5)
  IP_ADDRESS   : 管理ネットワークIP (172.16.100.x)
  CPU_CORES    : CPUコア数 (デフォルト: 16)
  MEMORY_GB    : メモリサイズGB (デフォルト: 128)
EOF
    exit 1
}

# 引数チェック
if [ -z "$VM_ID" ] || [ -z "$VM_NAME" ] || [ -z "$TARGET_NODE" ] || [ -z "$IP_ADDRESS" ]; then
    usage
fi

MEMORY_MB=$((MEMORY_GB * 1024))

echo "=== Kubernetes Worker VM 作成 ==="
echo "Template: $TEMPLATE_ID"
echo "VM ID: $VM_ID"
echo "VM Name: $VM_NAME"
echo "Target Node: $TARGET_NODE"
echo "IP Address: $IP_ADDRESS"
echo "CPU Cores: $CPU_CORES"
echo "Memory: ${MEMORY_GB}GB"
echo ""

# 1. テンプレートからクローン
echo "[1/5] テンプレートからクローン中..."
qm clone $TEMPLATE_ID $VM_ID --name $VM_NAME --full 1 --storage vm-storage --target $TARGET_NODE

sleep 5

# 2. リソース設定
echo "[2/5] リソース設定中..."
qm set $VM_ID --cores $CPU_CORES
qm set $VM_ID --memory $MEMORY_MB

# 3. Cloud-Init設定
echo "[3/5] Cloud-Init設定中..."
qm set $VM_ID --ipconfig0 ip=${IP_ADDRESS}/24,gw=172.16.100.1
qm set $VM_ID --ipconfig1 ip=172.16.200.${IP_ADDRESS##*.}/24
qm set $VM_ID --nameserver 150.65.0.1
qm set $VM_ID --searchdomain jaist.ac.jp
qm set $VM_ID --ciuser jaist-lab
qm set $VM_ID --cipassword jaileon02

# 4. Cloud-Init更新
echo "[4/5] Cloud-Init更新中..."
qm cloudinit update $VM_ID

# 5. 設定確認
echo "[5/5] 設定確認..."
echo ""
echo "=== VM設定 ==="
qm config $VM_ID | grep -E "name:|cores:|memory:|scsi|ipconfig|net"

echo ""
echo "========================================="
echo "✓ Worker VM作成完了: $VM_NAME ($VM_ID)"
echo "========================================="
echo ""
echo "次のステップ:"
echo "  1. VM起動: qm start $VM_ID"
echo "  2. SSH接続: ssh jaist-lab@${IP_ADDRESS}"

