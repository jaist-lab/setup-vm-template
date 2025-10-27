#!/bin/bash

# === r760xs1（172.16.100.11）のVM停止・削除 ===
ssh root@172.16.100.1 "qm    stop 121 --timeout 30 || true"
ssh root@172.16.100.1 "qm destroy 121 --purge"

# === r760xs2（172.16.100.12）のVM停止・削除 ===
ssh root@172.16.100.2 "qm    stop 122 --timeout 30 || true"
ssh root@172.16.100.2 "qm destroy 122 --purge"

# === r760xs3（172.16.100.13）のVM停止・削除 ===
ssh root@172.16.100.3 "qm    stop 123 --timeout 30 || true"
ssh root@172.16.100.3 "qm destroy 123 --purge"

# === r760xs4（172.16.100.14）のVM停止・削除 ===
ssh root@172.16.100.4 "qm    stop 124 --timeout 30 || true"
ssh root@172.16.100.4 "qm destroy 124 --purge"

# === r760xs5（172.16.100.15）のVM停止・削除 ===
ssh root@172.16.100.5 "qm    stop 125 --timeout 30 || true"
ssh root@172.16.100.5 "qm destroy 125 --purge"
