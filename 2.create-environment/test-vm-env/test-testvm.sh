#!/bin/bash

# 性能テスト（VM内で）
sudo fio --name=etcd-test \
  --ioengine=libaio \
  --direct=1 \
  --bs=4k \
  --rw=randwrite \
  --numjobs=1 \
  --iodepth=1 \
  --fsync=1 \
  --runtime=30 \
  --time_based \
  --filename=/var/lib/etcd/fio-test \
  --size=1G
