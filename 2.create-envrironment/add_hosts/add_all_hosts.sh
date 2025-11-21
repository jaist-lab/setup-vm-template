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

# management server(VM)
172.16.100.100 vessel
172.16.100.99  monitoring

# Production  servers(VM)
172.16.200.101  master01
172.16.200.102  master02
172.16.200.103  master03
172.16.200.104  node01
172.16.200.105  node02

# Development  servers(VM)
172.16.200.121  dev-master01
172.16.200.122  dev-master02
172.16.200.123  dev-master03
172.16.200.124  dev-node01
172.16.200.125  dev-node02

# Sandbox servers(VM)
172.16.200.131  sandbox-master01
172.16.200.132  sandbox-master02
172.16.200.133  sandbox-master03
172.16.200.134  sandbox-node01
172.16.200.135  sandbox-node02

EOF
