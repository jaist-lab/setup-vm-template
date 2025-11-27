#!/bin/bash
# create-vm.sh - Proxmox VM作成スクリプト（UEFI版 + etcd用ローカルNVMe対応）

# デフォルト値
DEFAULT_VM_ID=901
DEFAULT_VM_NAME="ubuntu-2404-vm"
DEFAULT_NODE="r760xs2"
DEFAULT_CPU_CORES=8
DEFAULT_MEMORY_GB=16
DEFAULT_DISK_GB=64
DEFAULT_ETCD_DISK_GB=0  # 0の場合はetcdディスクを作成しない

# 使用方法を表示する関数
usage() {
    cat << EOF
使用方法: $0 [オプション]

オプション:
    -i, --vm-id ID          VM ID (デフォルト: $DEFAULT_VM_ID)
    -n, --name NAME         VM名 (デフォルト: $DEFAULT_VM_NAME)
    -N, --node NODE         ノード名 (デフォルト: $DEFAULT_NODE)
    -c, --cores CORES       CPUコア数 (デフォルト: $DEFAULT_CPU_CORES)
    -m, --memory GB         メモリサイズ(GB) (デフォルト: $DEFAULT_MEMORY_GB)
    -d, --disk GB           システムディスクサイズ(GB) (デフォルト: $DEFAULT_DISK_GB)
    -e, --etcd-disk GB      etcd用ディスクサイズ(GB) (デフォルト: $DEFAULT_ETCD_DISK_GB, 0=無効)
    -h, --help              このヘルプを表示

例:
    $0 -i 902 -n "test-vm" -c 4 -m 8 -d 32
    $0 --vm-id 903 --name "k8s-master" --cores 8 --memory 16 --disk 64 --etcd-disk 32
    $0 -i 904 -n "k8s-node" -c 16 -m 32 -d 128 -e 50

ストレージ構成:
    - scsi0: vm-storage (Ceph RBD) - システムディスク
    - scsi1: local-nvme - etcd専用ディスク (--etcd-disk指定時のみ)

注意: 
    - このスクリプトはOVMF (UEFI) BIOSを使用します
    - etcdディスクはlocal-nvmeストレージに作成されます
    - Kubernetesマスターノード用にはetcdディスクの指定を推奨します

EOF
    exit 0
}

# パラメータの初期化
VM_ID=$DEFAULT_VM_ID
VM_NAME=$DEFAULT_VM_NAME
NODE=$DEFAULT_NODE
CPU_CORES=$DEFAULT_CPU_CORES
MEMORY_GB=$DEFAULT_MEMORY_GB
DISK_GB=$DEFAULT_DISK_GB
ETCD_DISK_GB=$DEFAULT_ETCD_DISK_GB

# コマンドライン引数の解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--vm-id)
            VM_ID="$2"
            shift 2
            ;;
        -n|--name)
            VM_NAME="$2"
            shift 2
            ;;
        -N|--node)
            NODE="$2"
            shift 2
            ;;
        -c|--cores)
            CPU_CORES="$2"
            shift 2
            ;;
        -m|--memory)
            MEMORY_GB="$2"
            shift 2
            ;;
        -d|--disk)
            DISK_GB="$2"
            shift 2
            ;;
        -e|--etcd-disk)
            ETCD_DISK_GB="$2"
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

# パラメータの検証
if ! [[ "$VM_ID" =~ ^[0-9]+$ ]] || [ "$VM_ID" -lt 100 ] || [ "$VM_ID" -gt 999999999 ]; then
    echo "エラー: VM IDは100以上の数値である必要があります" >&2
    exit 1
fi

if ! [[ "$CPU_CORES" =~ ^[0-9]+$ ]] || [ "$CPU_CORES" -lt 1 ]; then
    echo "エラー: CPUコア数は1以上の数値である必要があります" >&2
    exit 1
fi

if ! [[ "$MEMORY_GB" =~ ^[0-9]+$ ]] || [ "$MEMORY_GB" -lt 1 ]; then
    echo "エラー: メモリサイズは1GB以上である必要があります" >&2
    exit 1
fi

if ! [[ "$DISK_GB" =~ ^[0-9]+$ ]] || [ "$DISK_GB" -lt 1 ]; then
    echo "エラー: ディスクサイズは1GB以上である必要があります" >&2
    exit 1
fi

if ! [[ "$ETCD_DISK_GB" =~ ^[0-9]+$ ]]; then
    echo "エラー: etcdディスクサイズは0以上の数値である必要があります" >&2
    exit 1
fi

# メモリをMB単位に変換
MEMORY_MB=$((MEMORY_GB * 1024))

# エラーハンドラ関数
error_exit() {
    echo ""
    echo "========================================" >&2
    echo "✗ エラーが発生しました" >&2
    echo "========================================" >&2
    echo "VM ID: $VM_ID" >&2
    echo "VM Name: $VM_NAME" >&2
    echo "Node: $NODE" >&2
    echo "エラー内容: $1" >&2
    echo "終了コード: $2" >&2
    echo "========================================" >&2
    exit "${2:-1}"
}

# VMが既に存在するか確認
if qm status $VM_ID &>/dev/null; then
    echo "警告: VM ID $VM_ID は既に存在します"
    read -p "削除して再作成しますか? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "既存のVM $VM_ID を削除中..."
        qm destroy $VM_ID || error_exit "VM削除に失敗しました" $?
        echo "✓ VM削除完了"
    else
        echo "処理を中止しました"
        exit 0
    fi
fi

# etcdディスクの設定文字列を構築
ETCD_DISK_OPTION=""
ETCD_DISK_INFO="なし"
if [ "$ETCD_DISK_GB" -gt 0 ]; then
    ETCD_DISK_OPTION="--scsi1 local-nvme:${ETCD_DISK_GB},format=raw,cache=none,aio=native,discard=on,ssd=1"
    ETCD_DISK_INFO="${ETCD_DISK_GB}GB (local-nvme)"
fi

echo "=== VM作成を開始します ==="
echo "VM ID: $VM_ID"
echo "VM Name: $VM_NAME"
echo "Node: $NODE"
echo "BIOS: OVMF (UEFI)"
echo "CPU Cores: $CPU_CORES"
echo "Memory: ${MEMORY_GB}GB (${MEMORY_MB}MB)"
echo "System Disk: ${DISK_GB}GB (vm-storage/Ceph RBD)"
echo "etcd Disk: $ETCD_DISK_INFO"
echo "Network: vmbr0, vmbr100"
echo "Display: VirtIO-GPU"
echo ""

# VM作成コマンドを構築
QM_CMD="qm create $VM_ID \
  --name \"$VM_NAME\" \
  --bios ovmf \
  --machine q35 \
  --ostype l26 \
  --efidisk0 vm-storage:1,format=raw,efitype=4m,pre-enrolled-keys=1 \
  --ide2 cephfs-storage:iso/ubuntu-24.04.3-live-server-amd64.iso,media=cdrom \
  --scsi0 vm-storage:${DISK_GB},format=raw,cache=writeback,discard=on,ssd=1 \
  --scsihw virtio-scsi-pci \
  --sockets 1 \
  --cores $CPU_CORES \
  --cpu x86-64-v2-AES \
  --memory $MEMORY_MB \
  --balloon $MEMORY_MB \
  --net0 virtio,bridge=vmbr0 \
  --net1 virtio,bridge=vmbr100 \
  --vga virtio \
  --serial0 socket \
  --boot \"order=scsi0;ide2;net0\""

# etcdディスクオプションを追加
if [ -n "$ETCD_DISK_OPTION" ]; then
    QM_CMD="$QM_CMD $ETCD_DISK_OPTION"
fi

# VM作成実行
echo "VM作成コマンドを実行中..."
if ! eval $QM_CMD 2>&1; then
    error_exit "qm createコマンドの実行に失敗しました" $?
fi

echo ""
echo "========================================="
echo "✓ VM作成成功"
echo "========================================="
echo "VM ID: $VM_ID"
echo "VM Name: $VM_NAME"
echo "Node: $NODE"
echo "BIOS: OVMF (UEFI)"
echo "CPU Cores: $CPU_CORES"
echo "Memory: ${MEMORY_GB}GB"
echo ""
echo "=== ストレージ構成 ==="
echo "  scsi0: ${DISK_GB}GB - システムディスク (vm-storage/Ceph RBD)"
if [ "$ETCD_DISK_GB" -gt 0 ]; then
    echo "  scsi1: ${ETCD_DISK_GB}GB - etcd専用ディスク (local-nvme)"
fi
echo ""
echo "=== ネットワーク構成 ==="
echo "  net0: vmbr0 (DHCP)"
echo "  net1: vmbr100 (要固定IP設定)"
echo ""
echo "Display: VirtIO-GPU"
echo ""
echo "=== VM設定確認 ==="
qm config $VM_ID

echo ""
echo "=== ブート順序 ==="
qm config $VM_ID | grep boot

echo ""
echo "=== 次のステップ ==="
echo "1. VM起動: qm start $VM_ID"
echo "2. VM状態確認: qm status $VM_ID"
echo "3. コンソール接続: Proxmox WebUIから接続"
echo ""
echo "ブート順序: 1. HDD(scsi0) → 2. CD/DVD(ide2) → 3. Network(net0)"
echo ""
if [ "$ETCD_DISK_GB" -gt 0 ]; then
    echo "=== etcdディスクの設定（VM内で実行） ==="
    echo "# etcd専用ディスクのフォーマットとマウント"
    echo "sudo mkfs.ext4 -L etcd /dev/sdb"
    echo "sudo mkdir -p /var/lib/etcd"
    echo "sudo mount /dev/sdb /var/lib/etcd"
    echo "echo 'LABEL=etcd /var/lib/etcd ext4 defaults,noatime 0 2' | sudo tee -a /etc/fstab"
    echo ""
fi
echo "ネットワーク設定について:"
echo "  - vmbr0: DHCPで自動取得"
echo "  - vmbr100: インストール時またはcloud-initで固定IP設定が必要"
echo ""
echo "Proxmox Console(VNC)について:"
echo "  - ブラウザとの証明書の関係でVNCが表示されないことがあります。"
echo "  - その場合は、ブラウザをFirefoxで実行してください。"
