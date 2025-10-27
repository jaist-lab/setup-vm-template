#!/bin/bash -e
# Usage: ./create_vm.sh <VMID> <TARGET_NODE> <IP_ADDRESS1> <VM_NAME> [IP_ADDRESS2] [TEMPLATE_ID] [CORES] [MEMORY]
# VM作成スクリプト
# Arguments:
#   VMID         : 作成するVMのID (例: 101)
#   TARGET_NODE  : VM作成先のノード (例: r760xs3)
#   IP_ADDRESS1  : VMに割り当てる1つ目のIPアドレス (例:172.16.100.121)
#   VM_NAME      : VMの名前 (例: dev-master01)
#   IP_ADDRESS2  : VMに割り当てる2つ目のIPアドレス (オプション、例:172.16.200.121)  
#   TEMPLATE_ID  : テンプレートID (デフォルト: 901)
#   CORES        : CPUコア数 (デフォルト: テンプレートの設定を継承)
#   MEMORY       : メモリサイズMB (デフォルト: テンプレートの設定を継承)    

# 使用方法の表示
usage() {
    cat << EOF
使用方法: $0 <VMID> <TARGET_NODE> <IP_ADDRESS1> <VM_NAME> [IP_ADDRESS2] [TEMPLATE_ID] [CORES] [MEMORY]

引数:
  VMID         : 作成するVMのID (例: 101)
  TARGET_NODE  : VM作成先のノード (例: r760xs3)
  IP_ADDRESS1  : VMに割り当てる1つ目のIPアドレス (例: 172.16.100.101)
  VM_NAME      : VMの名前 (例: master01)
  IP_ADDRESS2  : VMに割り当てる2つ目のIPアドレス (オプション、例: 192.168.1.101)
  TEMPLATE_ID  : テンプレートID (デフォルト: 901)
  CORES        : CPUコア数 (デフォルト: テンプレートの設定を継承)
  MEMORY       : メモリサイズMB (デフォルト: テンプレートの設定を継承)

例:
  # IPアドレス1つの場合
  $0 101 r760xs3 172.16.100.101 master01

  # IPアドレス2つの場合
  $0 102 r760xs4 172.16.100.102 master02 192.168.1.102

  # IPアドレス2つ + その他のパラメータ
  $0 103 r760xs3 172.16.100.103 master03 192.168.1.103 901 8 65536

  # IP_ADDRESS2を省略する場合（後続パラメータを指定）
  $0 131 r760xs3 172.16.100.131 dev-node01 "" 902 4 32768

設定値:
  ゲートウェイ1: 172.16.100.1
  ゲートウェイ2: 192.168.1.1 (IP_ADDRESS2指定時)
  DNS: 150.65.0.1
  Search Domain: jaist.ac.jp
  ユーザー: jaist-lab
  パスワード: jaileon02
EOF
    exit 1
}

# 引数チェック
if [ $# -lt 4 ]; then
    echo "エラー: 引数が不足しています"
    usage
fi

# 引数の取得
VMID=$1
TARGET_NODE=$2
IP_ADDRESS1=$3
VM_NAME=$4
IP_ADDRESS2=$5
TEMPLATE_ID=${6:-901}
CORES=$7
MEMORY=$8

# ノードのIPアドレスマッピング
declare -A NODE_IPS=(
    ["r760xs1"]="172.16.100.11"
    ["r760xs2"]="172.16.100.12"
    ["r760xs3"]="172.16.100.13"
    ["r760xs4"]="172.16.100.14"
    ["r760xs5"]="172.16.100.15"
)

TARGET_IP=${NODE_IPS[$TARGET_NODE]}
if [ -z "$TARGET_IP" ]; then
    echo "エラー: 不明なノード名: $TARGET_NODE"
    echo "有効なノード: r760xs1, r760xs2, r760xs3, r760xs4, r760xs5"
    exit 1
fi

# 固定設定
GATEWAY1="172.16.100.1"
GATEWAY2="192.168.1.1"  # 2つ目のネットワーク用
DNS="150.65.0.1"
SEARCH_DOMAIN="jaist.ac.jp"
CI_USER="jaist-lab"
CI_PASSWORD="jaileon02"
STORAGE="vm-storage"

echo "========================================="
echo "VM作成スクリプト"
echo "========================================="
echo "VMID         : $VMID"
echo "ターゲットノード : $TARGET_NODE ($TARGET_IP)"
echo "IPアドレス1   : $IP_ADDRESS1/24"
if [ -n "$IP_ADDRESS2" ] && [ "$IP_ADDRESS2" != "" ]; then
    echo "IPアドレス2   : $IP_ADDRESS2/24"
fi
echo "VM名         : $VM_NAME"
echo "テンプレート  : $TEMPLATE_ID"
[ -n "$CORES" ] && echo "CPUコア      : $CORES"
[ -n "$MEMORY" ] && echo "メモリ       : ${MEMORY}MB"
echo "========================================="
echo ""

# VM削除（既存の場合）
echo "[1/6] 既存VMの削除..."
ssh root@$TARGET_IP "qm stop $VMID 2>/dev/null || true"
ssh root@$TARGET_IP "qm destroy $VMID 2>/dev/null || true"

# クローン作成
echo "[2/6] テンプレート${TEMPLATE_ID}からクローン作成中..."
qm clone $TEMPLATE_ID $VMID --name $VM_NAME --full --storage $STORAGE --target $TARGET_NODE

# 待機
echo "[3/6] 設定の安定化待機中..."
sleep 30

# Cloud-Init設定
echo "[4/6] Cloud-Init設定を適用中..."
# 1つ目のIPアドレス設定
ssh root@$TARGET_IP "qm set $VMID --ipconfig0 ip=$IP_ADDRESS1/24,gw=$GATEWAY1"

# 2つ目のIPアドレス設定（指定されている場合）
if [ -n "$IP_ADDRESS2" ] && [ "$IP_ADDRESS2" != "" ]; then
    echo "2つ目のIPアドレスを設定中..."
    ssh root@$TARGET_IP "qm set $VMID --ipconfig1 ip=$IP_ADDRESS2/24,gw=$GATEWAY2"
fi

ssh root@$TARGET_IP "qm set $VMID --nameserver $DNS"
ssh root@$TARGET_IP "qm set $VMID --searchdomain $SEARCH_DOMAIN"
ssh root@$TARGET_IP "qm set $VMID --ciuser $CI_USER"
ssh root@$TARGET_IP "qm set $VMID --cipassword $CI_PASSWORD"

# CPUとメモリの設定（指定された場合のみ）
if [ -n "$CORES" ]; then
    echo "CPUコア数を${CORES}に設定中..."
    ssh root@$TARGET_IP "qm set $VMID --cores $CORES"
fi

if [ -n "$MEMORY" ]; then
    echo "メモリを${MEMORY}MBに設定中..."
    ssh root@$TARGET_IP "qm set $VMID --memory $MEMORY"
fi

# 処理完了を待つための待ち時間
sleep 30
# Cloud-Init更新
ssh root@$TARGET_IP "qm cloudinit update $VMID"

# 設定確認
echo "[5/6] 設定確認..."
echo "=== VM設定 ==="
ssh root@$TARGET_IP "qm config $VMID | grep -E 'ipconfig|nameserver|searchdomain|cores|memory'"
echo ""
echo "=== Cloud-Init Network ==="
ssh root@$TARGET_IP "qm cloudinit dump $VMID network"
echo ""

sleep 30

# VM起動
echo "[6/6] VM起動中..."
ssh root@$TARGET_IP "qm start $VMID"
# 処理完了を待つための待ち時間
sleep 30

echo ""
echo "========================================="
echo "✓ VM作成完了"
echo "========================================="
echo "VMID: $VMID"
echo "ノード: $TARGET_NODE"
echo "IPアドレス1: $IP_ADDRESS1"
if [ -n "$IP_ADDRESS2" ] && [ "$IP_ADDRESS2" != "" ]; then
    echo "IPアドレス2: $IP_ADDRESS2"
fi
echo ""
echo "SSH接続テスト（30秒後に実行推奨）:"
echo "  ssh $CI_USER@$IP_ADDRESS1"
echo "========================================="