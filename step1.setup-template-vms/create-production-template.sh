#!/bin/bash

# ProductionテンプレートVM作成スクリプト
./create-vm.sh \
    --vm-id  901 \
    --name   "ubuntu-2404-production" \
    --cores  8 \
    --memory 128 \
    --disk   128