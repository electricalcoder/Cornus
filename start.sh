#!/bin/bash

/usr/sbin/sshd
cd /root/redis/src
./redis-server ../redis.conf
