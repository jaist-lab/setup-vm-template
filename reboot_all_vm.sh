#!/bin/bash
# 確認プロンプト

echo "reboot all VMs"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    log_info "Reset cancelled"
    exit 0
fi

ssh r760xs3 "qm reboot 101"
ssh r760xs3 "qm reboot 111"
ssh r760xs3 "qm reboot 121"
ssh r760xs3 "qm reboot 131"

ssh r760xs4 "qm reboot 102"
ssh r760xs4 "qm reboot 112"
ssh r760xs4 "qm reboot 122"
ssh r760xs4 "qm reboot 132"

ssh r760xs5 "qm reboot 103"
ssh r760xs5 "qm reboot 113"
ssh r760xs5 "qm reboot 123"
ssh r760xs5 "qm reboot 133"