#!/bin/bash

for i in $(seq 1 8); do
	docker rm -f cn$i
done
docker rm -f sn1

docker rmi cn sn base

docker builder prune

