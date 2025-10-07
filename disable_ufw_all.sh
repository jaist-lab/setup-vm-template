#!/bin/bash
# 確認プロンプト

echo "Disable ufw all VMs"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    log_info "Reset cancelled"
    exit 0
fi

ssh jaist-lab@master01 "sudo ufw disable" 
ssh jaist-lab@master02 "sudo ufw disable"
ssh jaist-lab@master03 "sudo ufw disable"
ssh jaist-lab@node01   "sudo ufw disable"    
ssh jaist-lab@node02   "sudo ufw disable"    
ssh jaist-lab@node03   "sudo ufw disable"    

ssh jaist-lab@dev-master01 "sudo ufw disable" 
ssh jaist-lab@dev-master02 "sudo ufw disable"
ssh jaist-lab@dev-master03 "sudo ufw disable"
ssh jaist-lab@dev-node01   "sudo ufw disable"    
ssh jaist-lab@dev-node02   "sudo ufw disable"    
ssh jaist-lab@dev-node03   "sudo ufw disable"    
