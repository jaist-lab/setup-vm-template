#!/bin/bash

# テスト用VMで確認（例: Sandboxで1台だけ）
../clone-and-configure-vm.sh \
  --template-id 900 \
  --vm-id 999 \
  --vm-name test-optimized \
  --target-node r760xs1 \
  --ip0 172.16.100.199 \
  --ip1 172.16.200.199 \
  --cores 4 \
  --memory 32 \
  --disk 64 \
  --etcd-disk 16

# VM起動
qm start 999

# 設定確認
qm config 999 | grep scsi1
