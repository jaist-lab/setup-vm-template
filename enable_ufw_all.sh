#!/bin/bash
# 確認プロンプト

echo "Enable ufw all VMs"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    log_info "Reset cancelled"
    exit 0
fi

ssh master01 "sudo ufw enable" 
ssh master02 "sudo ufw enable"
ssh master03 "sudo ufw enable"
ssh node01   "sudo ufw enable"    
ssh node02   "sudo ufw enable"    
ssh node03   "sudo ufw enable"    

ssh dev-master01 "sudo ufw enable" 
ssh dev-master02 "sudo ufw enable"
ssh dev-master03 "sudo ufw enable"
ssh dev-node01   "sudo ufw enable"    
ssh dev-node02   "sudo ufw enable"    
ssh dev-node03   "sudo ufw enable"    
