#!/bin/bash

# === r760xs3（172.16.100.13）のVM停止・削除 ===
ssh root@172.16.100.13 "qm stop 121 --timeout 30 || true"
ssh root@172.16.100.13 "qm destroy 121 --purge"

ssh root@172.16.100.13 "qm stop 131 --timeout 30 || true"
ssh root@172.16.100.13 "qm destroy 131 --purge"

# === r760xs4（172.16.100.14）のVM停止・削除 ===
ssh root@172.16.100.14 "qm stop 122 --timeout 30 || true"
ssh root@172.16.100.14 "qm destroy 122 --purge"

ssh root@172.16.100.14 "qm stop 132 --timeout 30 || true"
ssh root@172.16.100.14 "qm destroy 132 --purge"

# === r760xs5（172.16.100.15）のVM停止・削除 ===
ssh root@172.16.100.15 "qm stop 123 --timeout 30 || true"
ssh root@172.16.100.15 "qm destroy 123 --purge"

ssh root@172.16.100.15 "qm stop 133 --timeout 30 || true"
ssh root@172.16.100.15 "qm destroy 133 --purge"
