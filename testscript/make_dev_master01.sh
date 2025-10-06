# dev-master01 (VM 121)
qm clone 902 121 --name dev-master01 --full 1 --storage vm-storage --target r760xs3
ssh root@172.16.100.13 "qm set 121 \
  --cores 2 \
  --memory 16384 \
  --ipconfig0 ip=172.16.100.121/24,gw=172.16.100.1 \
  --nameserver 150.65.0.1 \
  --ciuser jaist-lab \
  --cipassword jaileon02"
ssh root@172.16.100.13 "qm cloudinit update 121"
