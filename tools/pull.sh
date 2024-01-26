#!/bin/bash
for i in $(seq 2 10); do
ssh 172.17.0.$i "cd /home/Cornus && git pull"
done

