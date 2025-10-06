#!/bin/bash -v

# master02 (VM 101)
qm clone 901 101 --name master01 --full 1 --storage vm-storage --target r760xs3
ssh root@172.16.100.13 "qm set 101 \
  --cores 2 \
  --memory 16384 \
  --ipconfig0 ip=172.16.100.101/24,gw=172.16.100.1 \
  --nameserver 150.65.0.1 \
  --ciuser jaist-lab \
  --searchdomain jaist.ac.jp \  # ← これが抜けている
  --cipassword jaileon02"
ssh root@172.16.100.13 "qm cloudinit update 101"

ssh root@172.16.100.13 "qm start 101"

# 各VMにSSH接続テスト
ssh jaist-lab@172.16.100.101 "hostname && ip addr show | grep 172.16.100.101"

pvesh get /cluster/resources --type vm

