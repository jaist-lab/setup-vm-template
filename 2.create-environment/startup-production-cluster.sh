#!/bin/bash

ssh 172.16.100.11 "qm start 101"
ssh 172.16.100.12 "qm start 102"
ssh 172.16.100.13 "qm start 103"
ssh 172.16.100.14 "qm start 104"
ssh 172.16.100.15 "qm start 105"

ssh 172.16.100.11 "qm status 101"
ssh 172.16.100.12 "qm status 102"
ssh 172.16.100.13 "qm status 103"
ssh 172.16.100.14 "qm status 104"
ssh 172.16.100.15 "qm status 105"

