#!/bin/bash

ssh jaist-lab@172.16.100.131 "qm start 131"
ssh jaist-lab@172.16.100.132 "qm start 132"
ssh jaist-lab@172.16.100.133 "qm start 133"
ssh jaist-lab@172.16.100.134 "qm start 134"
ssh jaist-lab@172.16.100.135 "qm start 135"

ssh jaist-lab@172.16.100.131 "qm status 131"
ssh jaist-lab@172.16.100.132 "qm status 132"
ssh jaist-lab@172.16.100.133 "qm status 133"
ssh jaist-lab@172.16.100.134 "qm status 134"
ssh jaist-lab@172.16.100.135 "qm status 135"

