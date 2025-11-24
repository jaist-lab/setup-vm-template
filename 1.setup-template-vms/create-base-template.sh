#!/bin/bash
# BaseテンプレートVM作成スクリプト
# etcdディスクは含めない（Masterノード作成時に追加）

./create-vm.sh \
    --vm-id  900 \
    --name   "ubuntu-2404-base" \
    --cores  4 \
    --memory 32 \
    --etcd-disk 0 \
    --disk   64
