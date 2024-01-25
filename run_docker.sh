#!/bin/bash

for i in $(seq 1 8); do
    echo creating compute node $i
    docker run -d --name cn$i --hostname cn$i cn
done
docker run -d --name sn0 --hostname sn0 sn
