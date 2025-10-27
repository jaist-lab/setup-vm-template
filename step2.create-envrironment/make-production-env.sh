#!/bin/bash
# create-production-vms.sh
# Usage: ./create_vm.sh <VMID> <TARGET_NODE> <IP_ADDRESS> <VM_NAME> [TEMPLATE_ID] [CORES] [MEMORY]

# control planes
./create_vm.sh 101 r760xs3 172.16.100.101 master01 172.16.200.101 901
./create_vm.sh 102 r760xs4 172.16.100.102 master02 172.16.200.102 901
./create_vm.sh 103 r760xs5 172.16.100.103 master03 172.16.200.103 901

# worker nodes
./create_vm.sh 104 r760xs3 172.16.100.104 node01 172.16.200.104   901
./create_vm.sh 105 r760xs4 172.16.100.105 node02 172.16.200.105   901

# 各ノードのVM確認
ssh root@r760xs1 "qm list | grep -E '101'"
ssh root@r760xs2 "qm list | grep -E '102'"
ssh root@r760xs3 "qm list | grep -E '103'"
ssh root@r760xs4 "qm list | grep -E '104'"
ssh root@r760xs5 "qm list | grep -E '105'"


# クラスタ全体のVM一覧
pvesh get /cluster/resources --type vm | grep -E "101|102|103|104|105"

