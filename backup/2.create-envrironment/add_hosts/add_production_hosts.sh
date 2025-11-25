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

# Production  servers(VM)
172.16.200.101  master01
172.16.200.102  master02
172.16.200.103  master03
172.16.200.104  node01
172.16.200.105  node02

EOF
