#!/bin/bash
# clone-and-configure-vm.sh - テンプレートからVMをクローンして設定する共通スクリプト（クロスノード対応完全版）

# ===================================
# エラーハンドリング設定
# ===================================
set -e  # エラー時に即座に終了

# ===================================
# 関数定義
# ===================================

# 使用方法を表示
usage() {
    cat << EOF
使用方法: $0 [オプション]

必須オプション:
    --template-id ID        テンプレートVM ID
    --vm-id ID              新規作成するVM ID
    --vm-name NAME          VM名
    --target-node NODE      配置先ノード名
    --ip0 IP                vmbr0のIPアドレス (例: 172.16.100.101)
    --ip1 IP                vmbr100のIPアドレス (例: 172.16.200.101)
    --cores CORES           CPUコア数
    --memory GB             メモリサイズ(GB)
    --disk GB               システムディスクサイズ(GB)

オプション:
    --etcd-disk GB          etcd専用ディスクサイズ(GB) (デフォルト: 0=作成しない)
    --gateway IP            デフォルトゲートウェイ (デフォルト: 172.16.100.1)
    --nameserver IP         DNSサーバー (デフォルト: 150.65.0.1)
    -h, --help              このヘルプを表示

例:
    # Masterノード作成 (etcdディスク付き)
    $0 --template-id 900 --vm-id 101 --vm-name master01 \\
       --target-node r760xs1 --ip0 172.16.100.101 --ip1 172.16.200.101 \\
       --cores 8 --memory 64 --disk 64 --etcd-disk 32

    # Workerノード作成 (etcdディスクなし)
    $0 --template-id 900 --vm-id 104 --vm-name node01 \\
       --target-node r760xs4 --ip0 172.16.100.104 --ip1 172.16.200.104 \\
       --cores 16 --memory 128 --disk 128

EOF
    exit 0
}

# エラー終了処理
error_exit() {
    echo ""
    echo "========================================" >&2
    echo "✗ エラーが発生しました" >&2
    echo "========================================" >&2
    echo "エラー内容: $1" >&2
    echo "========================================" >&2
    exit 1
}

# 進捗表示関数
print_step() {
    echo ""
    echo "========================================"
    echo ">>> $1"
    echo "========================================"
}

# qmコマンドをターゲットノードで実行する関数
qm_exec() {
    local vmid="$1"
    shift
    
    if [ "$TARGET_NODE" != "$CURRENT_NODE" ]; then
        # クロスノードの場合はSSH経由で実行
        ssh "$TARGET_NODE" "qm $*"
    else
        # 同一ノードの場合はローカル実行
        qm "$@"
    fi
}

# ===================================
# デフォルト値
# ===================================
ETCD_DISK_GB=0
GATEWAY="172.16.100.1"
NAMESERVER="150.65.0.1"

# ===================================
# コマンドライン引数の解析
# ===================================
while [[ $# -gt 0 ]]; do
    case $1 in
        --template-id)
            TEMPLATE_ID="$2"
            shift 2
            ;;
        --vm-id)
            VM_ID="$2"
            shift 2
            ;;
        --vm-name)
            VM_NAME="$2"
            shift 2
            ;;
        --target-node)
            TARGET_NODE="$2"
            shift 2
            ;;
        --ip0)
            IP_ADDRESS0="$2"
            shift 2
            ;;
        --ip1)
            IP_ADDRESS1="$2"
            shift 2
            ;;
        --cores)
            CPU_CORES="$2"
            shift 2
            ;;
        --memory)
            MEMORY_GB="$2"
            shift 2
            ;;
        --disk)
            DISK_GB="$2"
            shift 2
            ;;
        --etcd-disk)
            ETCD_DISK_GB="$2"
            shift 2
            ;;
        --gateway)
            GATEWAY="$2"
            shift 2
            ;;
        --nameserver)
            NAMESERVER="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "エラー: 不明なオプション: $1" >&2
            echo "ヘルプを表示するには -h または --help を使用してください" >&2
            exit 1
            ;;
    esac
done

# ===================================
# 必須パラメータのチェック
# ===================================
if [ -z "$TEMPLATE_ID" ] || [ -z "$VM_ID" ] || [ -z "$VM_NAME" ] || \
   [ -z "$TARGET_NODE" ] || [ -z "$IP_ADDRESS0" ] || [ -z "$IP_ADDRESS1" ] || \
   [ -z "$CPU_CORES" ] || [ -z "$MEMORY_GB" ] || [ -z "$DISK_GB" ]; then
    echo "エラー: 必須パラメータが不足しています" >&2
    usage
fi

# ===================================
# パラメータ検証
# ===================================
if ! [[ "$TEMPLATE_ID" =~ ^[0-9]+$ ]]; then
    error_exit "テンプレートIDは数値である必要があります"
fi

if ! [[ "$VM_ID" =~ ^[0-9]+$ ]]; then
    error_exit "VM IDは数値である必要があります"
fi

# テンプレートの存在確認
if ! qm status "$TEMPLATE_ID" &>/dev/null; then
    error_exit "テンプレートID $TEMPLATE_ID が存在しません"
fi

# テンプレートであることを確認
if ! qm config "$TEMPLATE_ID" | grep -q "template: 1"; then
    error_exit "VM ID $TEMPLATE_ID はテンプレートではありません"
fi

# ===================================
# 既存VMの確認と削除処理
# ===================================
if qm status "$VM_ID" &>/dev/null; then
    echo ""
    echo "========================================" >&2
    echo "警告: VM ID $VM_ID は既に存在します" >&2
    echo "========================================" >&2
    
    # VM情報を表示
    echo "既存VM情報:" >&2
    qm config "$VM_ID" | grep -E "^(name|cores|memory|net0|net1):" >&2
    echo "" >&2
    
    # 削除確認
    read -p "このVMを削除して再作成しますか? (yes/no): " -r REPLY
    echo ""
    
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]] || [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "VM ID $VM_ID を削除中..." >&2
        
        # VMが起動中の場合は停止
        VM_STATUS=$(qm status "$VM_ID" | grep -oP "status: \K\w+" || echo "unknown")
        if [ "$VM_STATUS" == "running" ]; then
            echo "VMを停止中..." >&2
            qm stop "$VM_ID" || error_exit "VM停止に失敗しました"
            sleep 3
        fi
        
        # VM削除
        qm destroy "$VM_ID" || error_exit "VM削除に失敗しました"
        echo "✓ VM削除完了" >&2
        echo "" >&2
        
        # 削除後、設定ファイルが完全にクリーンアップされるまで少し待機
        sleep 2
    else
        echo "処理を中止しました" >&2
        exit 0
    fi
fi

# メモリをMB単位に変換
MEMORY_MB=$((MEMORY_GB * 1024))

# 現在のノード名を取得
CURRENT_NODE=$(hostname -s)

# ===================================
# VM作成開始
# ===================================
print_step "VM作成パラメータ"
cat << EOF
テンプレートID: $TEMPLATE_ID
新規VM ID: $VM_ID
VM名: $VM_NAME
配置先ノード: $TARGET_NODE
CPUコア数: $CPU_CORES
メモリ: ${MEMORY_GB}GB (${MEMORY_MB}MB)
システムディスク: ${DISK_GB}GB
etcdディスク: ${ETCD_DISK_GB}GB $([ "$ETCD_DISK_GB" -eq 0 ] && echo "(作成しない)" || echo "(local-nvme)")
vmbr0 IP: $IP_ADDRESS0/24
vmbr100 IP: $IP_ADDRESS1/24
ゲートウェイ: $GATEWAY
DNSサーバー: $NAMESERVER
EOF

# ===================================
# ステップ1: テンプレートからクローン
# ===================================
print_step "ステップ1: テンプレートからクローン"

# クロスノードクローン時の既存設定ファイルクリーンアップ
if [ "$TARGET_NODE" != "$CURRENT_NODE" ]; then
    echo "クロスノードクローンを検出: ${CURRENT_NODE} → ${TARGET_NODE}"
    
    # 元ノードの設定ファイルを削除
    rm -f "/etc/pve/nodes/${CURRENT_NODE}/qemu-server/${VM_ID}.conf" 2>/dev/null || true
    
    # ターゲットノードの設定ファイルを削除
    ssh "$TARGET_NODE" "rm -f /etc/pve/nodes/${TARGET_NODE}/qemu-server/${VM_ID}.conf" 2>/dev/null || true
    
    # グローバル設定ファイルを削除
    rm -f "/etc/pve/qemu-server/${VM_ID}.conf" 2>/dev/null || true
    
    echo "✓ 既存設定ファイルのクリーンアップ完了"
    sleep 1
fi

# クローン実行
qm clone "$TEMPLATE_ID" "$VM_ID" \
    --name "$VM_NAME" \
    --full \
    --target "$TARGET_NODE" || error_exit "クローンに失敗しました"

echo "✓ クローン完了"

# クローン完了後、少し待機
sleep 2

# ===================================
# ステップ2: リソース設定変更
# ===================================
print_step "ステップ2: リソース設定変更"

# CPU設定（ターゲットノードで実行）
qm_exec "$VM_ID" set "$VM_ID" --cores "$CPU_CORES" || error_exit "CPU設定に失敗しました"
echo "✓ CPU: ${CPU_CORES}コア"

# メモリ設定（ターゲットノードで実行）
qm_exec "$VM_ID" set "$VM_ID" --memory "$MEMORY_MB" --balloon "$MEMORY_MB" || error_exit "メモリ設定に失敗しました"
echo "✓ メモリ: ${MEMORY_GB}GB"

# システムディスクのリサイズ（必要な場合のみ）
if [ "$TARGET_NODE" != "$CURRENT_NODE" ]; then
    CURRENT_DISK_SIZE=$(ssh "$TARGET_NODE" "qm config $VM_ID | grep '^scsi0:' | grep -oP 'size=\K[0-9]+G'" || echo "")
else
    CURRENT_DISK_SIZE=$(qm config "$VM_ID" | grep "^scsi0:" | grep -oP 'size=\K[0-9]+G' || echo "")
fi

if [ -z "$CURRENT_DISK_SIZE" ]; then
    echo "✓ システムディスク: ${DISK_GB}GB (サイズ情報取得不可 - スキップ)"
elif [ "$CURRENT_DISK_SIZE" != "${DISK_GB}G" ]; then
    qm_exec "$VM_ID" resize "$VM_ID" scsi0 "${DISK_GB}G" || error_exit "ディスクリサイズに失敗しました"
    echo "✓ システムディスク: ${DISK_GB}GB (リサイズ実行)"
else
    echo "✓ システムディスク: ${DISK_GB}GB (既に目標サイズ)"
fi

# ===================================
# ステップ3: etcdディスク追加 (必要な場合のみ)
# ===================================
if [ "$ETCD_DISK_GB" -gt 0 ]; then
    print_step "ステップ3: etcdディスク追加"
    
    # local-nvmeストレージが存在するか確認（ターゲットノードで）
    if [ "$TARGET_NODE" != "$CURRENT_NODE" ]; then
        STORAGE_CHECK=$(ssh "$TARGET_NODE" "pvesm status | grep -q 'local-nvme' && echo 'exists' || echo 'notfound'")
    else
        STORAGE_CHECK=$(pvesm status | grep -q "local-nvme" && echo "exists" || echo "notfound")
    fi
    
    if [ "$STORAGE_CHECK" != "exists" ]; then
        echo "警告: local-nvmeストレージが存在しません。スキップします。" >&2
    else
        # etcdディスクを追加（ターゲットノードで実行）
        qm_exec "$VM_ID" set "$VM_ID" \
            --scsi1 "local-nvme:${ETCD_DISK_GB},format=raw,cache=writeback,discard=on,ssd=1" \
            || error_exit "etcdディスク追加に失敗しました"
        echo "✓ etcdディスク追加: ${ETCD_DISK_GB}GB (local-nvme, /dev/sdb)"
    fi
else
    echo ""
    echo ">>> etcdディスクは作成しません (Workerノード)"
fi

# ===================================
# ステップ4: Cloud-Init設定
# ===================================
print_step "ステップ4: Cloud-Init設定"

# Cloud-Init用ドライブを追加（ターゲットノードで実行）
qm_exec "$VM_ID" set "$VM_ID" --ide2 vm-storage:cloudinit || error_exit "Cloud-Initドライブ追加に失敗しました"
echo "✓ Cloud-Initドライブ追加: vm-storage (Ceph RBD)"

# ユーザー設定（ターゲットノードで実行）
qm_exec "$VM_ID" set "$VM_ID" --ciuser jaist-lab || error_exit "ユーザー設定に失敗しました"
echo "✓ ユーザー: jaist-lab"

# パスワード設定（ターゲットノードで実行）
qm_exec "$VM_ID" set "$VM_ID" --cipassword "jaileon02" || error_exit "パスワード設定に失敗しました"
echo "✓ パスワード: ********"

# SSHキー設定（ターゲットノードで実行）
SSH_KEY_PATH="/root/.ssh/id_rsa.pub"
if [ -f "$SSH_KEY_PATH" ]; then
    qm_exec "$VM_ID" set "$VM_ID" --sshkeys "$SSH_KEY_PATH" || error_exit "SSHキー設定に失敗しました"
    echo "✓ SSHキー: $SSH_KEY_PATH"
else
    echo "警告: SSH公開鍵が見つかりません ($SSH_KEY_PATH)" >&2
fi

# ===================================
# ステップ5: ネットワーク設定
# ===================================
print_step "ステップ5: ネットワーク設定"

# vmbr0 (管理ネットワーク) の設定（ターゲットノードで実行）
qm_exec "$VM_ID" set "$VM_ID" --ipconfig0 "ip=${IP_ADDRESS0}/24,gw=${GATEWAY}" || error_exit "vmbr0ネットワーク設定に失敗しました"
echo "✓ vmbr0: ${IP_ADDRESS0}/24, GW: ${GATEWAY}"

# vmbr100 (Cephネットワーク) の設定（ターゲットノードで実行）
qm_exec "$VM_ID" set "$VM_ID" --ipconfig1 "ip=${IP_ADDRESS1}/24" || error_exit "vmbr100ネットワーク設定に失敗しました"
echo "✓ vmbr100: ${IP_ADDRESS1}/24"

# DNS設定（ターゲットノードで実行）
qm_exec "$VM_ID" set "$VM_ID" --nameserver "$NAMESERVER" || error_exit "DNS設定に失敗しました"
echo "✓ DNS: $NAMESERVER"

# ===================================
# ステップ6: 起動順序設定
# ===================================
print_step "ステップ6: 起動順序設定"
qm_exec "$VM_ID" set "$VM_ID" --boot "order=scsi0;net0" || error_exit "起動順序設定に失敗しました"
echo "✓ 起動順序: scsi0 → net0"

# ===================================
# 完了メッセージ
# ===================================
print_step "VM作成完了"
cat << EOF
========================================
✓ VM作成成功
========================================
VM ID: $VM_ID
VM名: $VM_NAME
配置先: $TARGET_NODE

=== リソース構成 ===
CPU: ${CPU_CORES}コア
メモリ: ${MEMORY_GB}GB
システムディスク: ${DISK_GB}GB (vm-storage/Ceph RBD)
$([ "$ETCD_DISK_GB" -gt 0 ] && echo "etcdディスク: ${ETCD_DISK_GB}GB (local-nvme, /dev/sdb)")

=== ネットワーク構成 ===
vmbr0: ${IP_ADDRESS0}/24 (管理ネットワーク)
vmbr100: ${IP_ADDRESS1}/24 (Cephネットワーク)
ゲートウェイ: ${GATEWAY}
DNS: $NAMESERVER

=== Cloud-Init設定 ===
ユーザー: jaist-lab
パスワード: jaileon02
SSHキー: 設定済み

=== 次のステップ ===
1. VM起動: qm start $VM_ID
2. 起動確認: qm status $VM_ID
3. IPアドレス確認: qm guest cmd $VM_ID network-get-interfaces
4. SSH接続: ssh jaist-lab@${IP_ADDRESS0}

$([ "$ETCD_DISK_GB" -gt 0 ] && cat << 'ETCD_MSG'
=== etcdディスクについて ===
- /dev/sdb として認識されます
- 初回起動時に setup-etcd-disk.service が自動実行されます
- 自動的にフォーマットされ /var/lib/etcd にマウントされます
- journalctl -u setup-etcd-disk.service で実行ログを確認できます
ETCD_MSG
)

========================================
EOF
