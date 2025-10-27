#!/bin/bash
# create-sandbox-vms.sh
# Usage: ./create_vm.sh <VMID> <TARGET_NODE> <IP_ADDRESS> <VM_NAME> [TEMPLATE_ID] [CORES] [MEMORY]

# control planes
./create_vm.sh 131 r760xs1 172.16.100.131 sandbox-master01 902
./create_vm.sh 132 r760xs2 172.16.100.132 sandbox-master02 902
./create_vm.sh 133 r760xs3 172.16.100.133 sandbox-master03 902

# worker nodes
./create_vm.sh 134 r760xs4 172.16.100.134 sandbox-node21   902
./create_vm.sh 135 r760xs5 172.16.100.135 sandbox-node22   902

# 各ノードのVM確認
ssh root@r760xs1 "qm list | grep -E '131'"
ssh root@r760xs2 "qm list | grep -E '132'"
ssh root@r760xs3 "qm list | grep -E '133'"
ssh root@r760xs4 "qm list | grep -E '134'"
ssh root@r760xs5 "qm list | grep -E '135'"

# クラスタ全体のVM一覧
pvesh get /cluster/resources --type vm | grep -E "131|132|133|134|135"

