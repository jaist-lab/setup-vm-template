#!/bin/bash
# create-development-vms.sh
# Usage: ./create_vm.sh <VMID> <TARGET_NODE> <IP_ADDRESS> <VM_NAME> [TEMPLATE_ID] [CORES] [MEMORY]

# control planes
./create_vm.sh 121 r760xs3 172.16.100.121 dev-master01 902
./create_vm.sh 122 r760xs4 172.16.100.122 dev-master02 902
./create_vm.sh 123 r760xs5 172.16.100.123 dev-master03 902

# worker nodes
./create_vm.sh 131 r760xs3 172.16.100.131 dev-node01   902
./create_vm.sh 132 r760xs4 172.16.100.132 dev-node02   902
./create_vm.sh 133 r760xs5 172.16.100.133 dev-node03   902

# 各ノードのVM確認
ssh root@r760xs3 "qm list | grep -E '121|131'"
ssh root@r760xs4 "qm list | grep -E '122|132'"
ssh root@r760xs5 "qm list | grep -E '123|133'"

# クラスタ全体のVM一覧
pvesh get /cluster/resources --type vm | grep -E "121|122|123|131|132|133"

