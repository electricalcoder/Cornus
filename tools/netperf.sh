#!/bin/bash


for i in $(seq 2 9); do
    for j in $(seq 2 9); do
	lat=$(ssh 172.17.0.$i ping -c 1 172.17.0.$j | awk 'BEGIN {FS="[=]|[ ]"} NR==2 {print $10}')
	echo lat c.$i to c.$j: $lat
    done
    for j in $(seq 1 1); do
	lat=$(ssh 172.17.0.$i ping -c 1 172.17.0.$j | awk 'BEGIN {FS="[=]|[ ]"} NR==2 {print $10}')
	echo lat c.$i to s.$j: $lat
    done
done
