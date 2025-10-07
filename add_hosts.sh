#!/bin/bash
# 確認プロンプト
echo "Add hosts entries"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM     
if [ "$CONFIRM" != "yes" ]; then
    log_info "Operation cancelled"
    exit 0
fi

sudo tee -a /etc/hosts << 'EOF'

#  Testbed servers
172.16.100.11   r760xs1
172.16.100.12   r760xs2
172.16.100.13   r760xs3
172.16.100.14   r760xs4
172.16.100.15   r760xs5

172.16.100.31   dlcsv1
172.16.100.32   dlcsv2
172.16.100.33   dlcsv3
172.16.100.34   dlcsv4

# Production  servers
172.16.100.101  master01
172.16.100.102  master02
172.16.100.103  master03
172.16.100.111  node01
172.16.100.112  node02
172.16.100.113  node03

# Development  servers
172.16.100.121  dev-master01
172.16.100.122  dev-master02
172.16.100.123  dev-master03
172.16.100.131  dev-node01
172.16.100.132  dev-node02
172.16.100.133  dev-node03
EOF
