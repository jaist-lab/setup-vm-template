#!/bin/bash

# テストVMの削除
qm stop 999 && qm destroy 999 --purge

