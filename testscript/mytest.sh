#!/bin/bash -vx

# VM削除（既存の場合）
ssh root@172.16.100.13 "qm stop 101 || true"
ssh root@172.16.100.13 "qm destroy 101 || true"

# クローン作成
qm clone 901 101 --name master01 --full 1 --storage vm-storage --target r760xs3

# 5秒待機
sleep 5

# Cloud-Init設定
ssh root@172.16.100.13 "qm set 101 --ipconfig0 ip=172.16.100.101/24,gw=172.16.100.1"
ssh root@172.16.100.13 "qm set 101 --nameserver 150.65.0.1"
ssh root@172.16.100.13 "qm set 101 --searchdomain jaist.ac.jp"
ssh root@172.16.100.13 "qm set 101 --ciuser jaist-lab"
ssh root@172.16.100.13 "qm set 101 --cipassword jaileon02"

# Cloud-Init更新
ssh root@172.16.100.13 "qm cloudinit update 101"

# 設定確認
echo "=== VM設定 ==="
ssh root@172.16.100.13 "qm config 101 | grep -E 'ipconfig|nameserver|searchdomain'"

echo "=== Cloud-Init Network ==="
ssh root@172.16.100.13 "qm cloudinit dump 101 network"

# VM起動
ssh root@172.16.100.13 "qm start 101"
