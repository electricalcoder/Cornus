#!/bin/bash


echo Measure latency...
for i in $(seq 2 10); do
    echo ====================================================
    for j in $(seq 2 10); do
	lat=$(ssh 172.17.0.$i ping -c 1 172.17.0.$j | awk 'BEGIN {FS="[=]|[ ]"} NR==2 {print $10}')
	echo lat 172.17.0.$i to 172.17.0.$j: $lat ms
    done
done

echo Measure BW...
for i in $(seq 2 10); do
    echo launch iperf server on .$i
    ssh 172.17.0.$i pkill iperf
    ssh 172.17.0.$i iperf -s &
done
for i in $(seq 2 10); do
    echo ====================================================
    for j in $(seq 2 10); do	
    	bw=$(ssh 172.17.0.$i iperf -c 172.17.0.$j | awk 'BEGIN {FS="[=]|[ ]"} NR==7 {print $7}'
	echo bw 172.17.0.$i to 172.17.0.$j: $bw Gbps
    done
done
for i in $(seq 2 10); do
    ssh 172.17.0.$i pkill iperf
done

