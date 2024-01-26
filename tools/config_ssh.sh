#!/bin/bash
ssh-keygen -o
for i in $(seq 2 10); do
ssh-copy-id root@172.17.0.$i
done

