#!/bin/bash

ssh jaist-lab@172.16.100.11 "qm start 131"
ssh jaist-lab@172.16.100.12 "qm start 132"
ssh jaist-lab@172.16.100.13 "qm start 133"
ssh jaist-lab@172.16.100.14 "qm start 134"
ssh jaist-lab@172.16.100.15 "qm start 135"

ssh jaist-lab@172.16.100.11 "qm status 131"
ssh jaist-lab@172.16.100.12 "qm status 132"
ssh jaist-lab@172.16.100.13 "qm status 133"
ssh jaist-lab@172.16.100.14 "qm status 134"
ssh jaist-lab@172.16.100.15 "qm status 135"

