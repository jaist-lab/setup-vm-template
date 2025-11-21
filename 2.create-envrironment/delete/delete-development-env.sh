#!/bin/bash

# 確認プロンプト
echo "Delete development environment VMs"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM     
if [ "$CONFIRM" != "yes" ]; then
    echo "Operation cancelled"
    exit 0
fi

# === r760xs1（172.16.100.11）のVM停止・削除 ===
ssh root@172.16.100.11 "qm    stop 121 --timeout 30 || true"
ssh root@172.16.100.11 "qm destroy 121 --purge"

# === r760xs2（172.16.100.12）のVM停止・削除 ===
ssh root@172.16.100.12 "qm    stop 122 --timeout 30 || true"
ssh root@172.16.100.12 "qm destroy 122 --purge"

# === r760xs3（172.16.100.13）のVM停止・削除 ===
ssh root@172.16.100.13 "qm    stop 123 --timeout 30 || true"
ssh root@172.16.100.13 "qm destroy 123 --purge"

# === r760xs4（172.16.100.14）のVM停止・削除 ===
ssh root@172.16.100.14 "qm    stop 124 --timeout 30 || true"
ssh root@172.16.100.14 "qm destroy 124 --purge"

# === r760xs5（172.16.100.15）のVM停止・削除 ===
ssh root@172.16.100.15 "qm    stop 125 --timeout 30 || true"
ssh root@172.16.100.15 "qm destroy 125 --purge"
