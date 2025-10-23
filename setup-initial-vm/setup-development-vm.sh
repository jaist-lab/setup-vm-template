#!/bin/bash
# create-development-vm.sh

VM_ID=902
VM_NAME="ubuntu-2404-development"
NODE="r760xs2"

# エラーハンドラ関数
error_exit() {
    echo ""
    echo "========================================" >&2
    echo "✗ エラーが発生しました" >&2
    echo "========================================" >&2
    echo "VM ID: $VM_ID" >&2
    echo "VM Name: $VM_NAME" >&2
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

echo "=== VM作成を開始します ==="
echo "VM ID: $VM_ID"
echo "VM Name: $VM_NAME"
echo ""

# VM作成実行
echo "VM作成コマンドを実行中..."
if ! qm create $VM_ID \
  --name "$VM_NAME" \
  --ostype l26 \
  --ide2 cephfs-storage:iso/ubuntu-24.04.3-live-server-amd64.iso,media=cdrom \
  --scsi0 vm-storage:96,format=raw,cache=writeback,discard=on,ssd=1 \
  --scsihw virtio-scsi-pci \
  --sockets 1 \
  --cores 2 \
  --cpu x86-64-v2-AES \
  --memory 16384 \
  --balloon 16384 \
  --net0 virtio,bridge=vmbr0 \
  --serial0 socket \
  --boot "order=scsi0;ide2;net0" 2>&1; then

  error_exit "qm createコマンドの実行に失敗しました" $?
fi

echo ""
echo "========================================="
echo "✓ VM作成成功"
echo "========================================="
echo "VM ID: $VM_ID"
echo "VM Name: $VM_NAME"
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
echo ""
echo "ブート順序: 1. HDD(scsi0) → 2. CD/DVD(ide2) → 3. Network(net0)"