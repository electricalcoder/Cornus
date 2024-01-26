#!/bin/bash

for i in $(seq 1 8); do
    echo creating compute node $i
    docker run --privileged -d --name cn$i --hostname cn$i cn
done
docker run --privileged -d --name sn0 --hostname sn1 sn

