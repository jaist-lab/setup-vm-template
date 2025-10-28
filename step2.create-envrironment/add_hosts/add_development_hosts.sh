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

# Development  servers(VM)
172.16.200.121  dev-master01
172.16.200.122  dev-master02
172.16.200.123  dev-master03
172.16.200.124  dev-node01
172.16.200.125  dev-node02

EOF
