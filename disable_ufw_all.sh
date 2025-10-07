#!/bin/bash
# 確認プロンプト

echo "Disable ufw all VMs"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    log_info "Reset cancelled"
    exit 0
fi

ssh master01 "sudo ufw disable" 
ssh master02 "sudo ufw disable"
ssh master03 "sudo ufw disable"
ssh node01   "sudo ufw disable"    
ssh node02   "sudo ufw disable"    
ssh node03   "sudo ufw disable"    

ssh dev-master01 "sudo ufw disable" 
ssh dev-master02 "sudo ufw disable"
ssh dev-master03 "sudo ufw disable"
ssh dev-node01   "sudo ufw disable"    
ssh dev-node02   "sudo ufw disable"    
ssh dev-node03   "sudo ufw disable"    
