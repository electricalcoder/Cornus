#!/bin/bash
source setup_env.sh
cd /home/Cornus/src
mkdir -p /home/Cornus/outputs
./rundb $1
