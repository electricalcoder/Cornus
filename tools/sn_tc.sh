#!/bin/bash

SS_BW=12Gbit
SC_BW=12Gbit
DEFAULT_BW=12Gbit
SS_LAT=250us
SC_LAT=1ms
DEFAULT_LAT=10us

tc qdisc add dev eth0 root handle 1:0 htb default 3
for i in {2..9}; do
    tc filter add dev eth0 parent 1:0 prior 1 protocol ip u32 match ip dst 172.17.0.$i classid 1:2
done
for i in {10..10}; do
    tc filter add dev eth0 parent 1:0 prior 3 protocol ip u32 match ip dst 172.17.0.$i classid 1:1
done
tc class add dev eth0 parent 1:0 classid 1:1 htb rate $SS_BW
tc class add dev eth0 parent 1:0 classid 1:2 htb rate $SC_BW
tc class add dev eth0 parent 1:0 classid 1:3 htb rate $DEFAULT_BW
tc qdisc add dev eth0 parent 1:1 handle 2:0 netem delay $SS_LAT
tc qdisc add dev eth0 parent 1:2 handle 3:0 netem delay $SC_LAT
tc qdisc add dev eth0 parent 1:3 handle 4:0 netem delay $DEFAULT_LAT

