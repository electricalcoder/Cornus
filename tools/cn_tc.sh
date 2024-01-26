#!/bin/bash

CC_BW=10Gbit
CS_BW=10Gbit
DEFAULT_BW=10Gbit
CC_LAT=100ms
CS_LAT=100ms
DEFAULT_LAT=100ms

for i in {2..9}; do
    iptables -t mangle -A PREROUTING -s 172.17.0.$i -j MARK --set-mark 1001
done
iptables -t mangle -A PREROUTING -s 172.17.0.10 -j MARK --set-mark 1002
iptables -t mangle -L -v -n

tc qdisc add dev eth0 root handle 1:0 htb default 3
tc filter add dev eth0 protocol ip parent 1:0 prio 1 handle 1001 fw classid 1:1
tc filter add dev eth0 protocol ip parent 1:0 prio 1 handle 1002 fw classid 1:2
tc class add dev eth0 parent 1:0 classid 1:1 htb rate $CC_BW
tc class add dev eth0 parent 1:0 classid 1:2 htb rate $CS_BW
tc class add dev eth0 parent 1:0 classid 1:3 htb rate $DEFAULT_BW
tc qdisc add dev eth0 parent 1:1 handle 2:0 netem delay $CC_LAT
tc qdisc add dev eth0 parent 1:2 handle 3:0 netem delay $CS_LAT
tc qdisc add dev eth0 parent 1:3 handle 4:0 netem delay $DEFAULT_LAT
