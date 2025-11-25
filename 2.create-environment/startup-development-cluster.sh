#!/bin/bash

ssh 172.16.100.11 "qm start 121"
ssh 172.16.100.12 "qm start 122"
ssh 172.16.100.13 "qm start 123"
ssh 172.16.100.14 "qm start 124"
ssh 172.16.100.15 "qm start 125"

ssh 172.16.100.11 "qm status 121"
ssh 172.16.100.12 "qm status 122"
ssh 172.16.100.13 "qm status 123"
ssh 172.16.100.14 "qm status 124"
ssh 172.16.100.15 "qm status 125"

