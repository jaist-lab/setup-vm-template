#!/bin/bash

VMID=122
STORAGE="vm-storage"
TARGET_NODE="r760xs2"

echo "========================================="
echo "VM $VMID クリーンアップと再作成"
echo "========================================="

# r760xs2でVM削除
echo "[1/4] VM削除中..."
ssh root@172.16.100.12 "
    qm unlock $VMID 2>/dev/null || true
    qm stop $VMID --skiplock 2>/dev/null || true
    sleep 3
    qm destroy $VMID --purge --skiplock 2>/dev/null || true
"

# 設定ファイル削除
echo "[2/4] 設定ファイル削除中..."
ssh root@172.16.100.12 "rm -f /etc/pve/qemu-server/${VMID}.conf 2>/dev/null || true"
rm -f /etc/pve/qemu-server/${VMID}.conf 2>/dev/null || true

sleep 5

# RBDイメージ削除（r760xs1から実行）
echo "[3/4] RBDイメージ削除中..."
for image in $(rbd ls $STORAGE 2>/dev/null | grep "^vm-${VMID}-"); do
    echo "  削除: $image"
    # スナップショット削除
    rbd snap ls $STORAGE/$image 2>/dev/null | tail -n +2 | awk '{print $2}' | while read snap; do
        rbd snap unprotect $STORAGE/$image@$snap 2>/dev/null || true
        rbd snap rm $STORAGE/$image@$snap 2>/dev/null || true
    done
    # イメージ削除
    rbd rm $STORAGE/$image 2>/dev/null || true
done

sleep 5

# 確認
echo "[4/4] 削除確認..."
echo "=== VM一覧 ==="
ssh root@172.16.100.12 "qm list | grep $VMID" && echo "  警告: VMが残っています" || echo "  ✓ VM削除完了"

echo ""
echo "=== RBDイメージ ==="
rbd ls $STORAGE | grep "vm-${VMID}-" && echo "  警告: イメージが残っています" || echo "  ✓ RBDイメージ削除完了"

echo ""
echo "========================================="
echo "✓ クリーンアップ完了"
echo "========================================="
echo ""
echo "10秒後にVM再作成を実行してください"
