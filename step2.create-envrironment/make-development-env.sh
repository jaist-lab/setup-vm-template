#!/bin/bash
# create-development-vms.sh
# Usage: ./create_vm.sh <VMID> <TARGET_NODE> <IP_ADDRESS> <VM_NAME> [TEMPLATE_ID] [CORES] [MEMORY]

# 確認プロンプト
echo "Create development environment VMs"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM     
if [ "$CONFIRM" != "yes" ]; then
    echo "Operation cancelled"
    exit 0
fi

# control planes
./create_vm.sh 121 r760xs1 172.16.100.121 dev-master01 172.16.200.121 902
./create_vm.sh 122 r760xs2 172.16.100.122 dev-master02 172.16.200.122 902
./create_vm.sh 123 r760xs3 172.16.100.123 dev-master03 172.16.200.123 902

# worker nodes
./create_vm.sh 124 r760xs4 172.16.100.124 dev-node01 172.16.200.124 902
./create_vm.sh 125 r760xs5 172.16.100.125 dev-node02 172.16.200.125 902

# 各ノードのVM確認
ssh root@r760xs1 "qm list | grep -E '121'"
ssh root@r760xs2 "qm list | grep -E '122'"
ssh root@r760xs3 "qm list | grep -E '123'"
ssh root@r760xs4 "qm list | grep -E '124'"
ssh root@r760xs5 "qm list | grep -E '125'"

# クラスタ全体のVM一覧
pvesh get /cluster/resources --type vm | grep -E "121|122|123|124|125"

