#!/bin/bash
# create-production-vms.sh
# Usage: ./create_vm.sh <VMID> <TARGET_NODE> <IP_ADDRESS> <VM_NAME> [TEMPLATE_ID] [CORES] [MEMORY]

# control planes
./create_vm.sh 101 r760xs3 172.16.100.101 master01 901
./create_vm.sh 102 r760xs4 172.16.100.102 master02 901
./create_vm.sh 103 r760xs5 172.16.100.103 master03 901

# worker nodes
./create_vm.sh 111 r760xs3 172.16.100.111 node01   901
./create_vm.sh 112 r760xs4 172.16.100.112 node02   901
./create_vm.sh 113 r760xs5 172.16.100.113 node03   901

# 各ノードのVM確認
ssh root@r760xs3 "qm list | grep -E '101|111'"
ssh root@r760xs4 "qm list | grep -E '102|112'"
ssh root@r760xs5 "qm list | grep -E '103|113'"

# クラスタ全体のVM一覧
pvesh get /cluster/resources --type vm | grep -E "101|102|103|111|112|113"

