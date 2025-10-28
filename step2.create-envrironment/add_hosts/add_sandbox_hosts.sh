#!/bin/bash
# 確認プロンプト
echo "Add Development environment hosts entries"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM     
if [ "$CONFIRM" != "yes" ]; then
    log_info "Operation cancelled"
    exit 0
fi

sudo tee -a /etc/hosts << 'EOF'

# management server(VM)
172.16.100.100 vessel
172.16.100.99  monitoring

# Sandbox servers(VM)
172.16.200.131  sandbox-master01
172.16.200.132  sandbox-master02
172.16.200.133  sandbox-master03
172.16.200.134  sandbox-node01
172.16.200.135  sandbox-node02

EOF
