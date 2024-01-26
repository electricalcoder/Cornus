#!/bin/bash
for i in $(seq 2 9); do
ssh 172.17.0.$i /home/Cornus/tools/cn_tc.sh
done
for i in $(seq 10 10); do
ssh 172.17.0.$i /home/Cornus/tools/sn_tc.sh
done

