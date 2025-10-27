#!/bin/bash

# === r760xs1（172.16.100.11）のVM停止・削除 ===
ssh root@172.16.100.1 "qm    stop 101 --timeout 30 || true"
ssh root@172.16.100.1 "qm destroy 101 --purge"

# === r760xs2（172.16.100.12）のVM停止・削除 ===
ssh root@172.16.100.2 "qm    stop 102 --timeout 30 || true"
ssh root@172.16.100.2 "qm destroy 102 --purge"

# === r760xs3（172.16.100.13）のVM停止・削除 ===
ssh root@172.16.100.3 "qm    stop 103 --timeout 30 || true"
ssh root@172.16.100.3 "qm destroy 103 --purge"

# === r760xs4（172.16.100.14）のVM停止・削除 ===
ssh root@172.16.100.4 "qm    stop 104 --timeout 30 || true"
ssh root@172.16.100.4 "qm destroy 104 --purge"

# === r760xs5（172.16.100.15）のVM停止・削除 ===
ssh root@172.16.100.5 "qm    stop 105 --timeout 30 || true"
ssh root@172.16.100.5 "qm destroy 105 --purge"
