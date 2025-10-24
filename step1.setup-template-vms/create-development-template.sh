#!/bin/bash

# ProductionテンプレートVM作成スクリプト
./create-vm.sh \
    --vm-id  902 \
    --name   "ubuntu-2404-development" \
    --cores  2 \
    --memory 32 \
    --disk   64