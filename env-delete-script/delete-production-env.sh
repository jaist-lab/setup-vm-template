#!/bin/bash

# === r760xs3（172.16.100.13）のVM停止・削除 ===
ssh root@172.16.100.13 "qm stop 101 --timeout 30 || true"
ssh root@172.16.100.13 "qm destroy 101 --purge"

ssh root@172.16.100.13 "qm stop 111 --timeout 30 || true"
ssh root@172.16.100.13 "qm destroy 111 --purge"

# === r760xs4（172.16.100.14）のVM停止・削除 ===
ssh root@172.16.100.14 "qm stop 102 --timeout 30 || true"
ssh root@172.16.100.14 "qm destroy 102 --purge"

ssh root@172.16.100.14 "qm stop 112 --timeout 30 || true"
ssh root@172.16.100.14 "qm destroy 112 --purge"

# === r760xs5（172.16.100.15）のVM停止・削除 ===
ssh root@172.16.100.15 "qm stop 103 --timeout 30 || true"
ssh root@172.16.100.15 "qm destroy 103 --purge"

ssh root@172.16.100.15 "qm stop 113 --timeout 30 || true"
ssh root@172.16.100.15 "qm destroy 113 --purge"
