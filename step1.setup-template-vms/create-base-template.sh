#!/bin/bash

# BasetテンプレートVM作成スクリプト
./create-vm.sh \
    --vm-id  900 \
    --name   "ubuntu-2404-base" \
    --cores  2 \
    --memory 32 \
    --disk   64