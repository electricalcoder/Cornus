#!/bin/bash
source /home/Cornus/tools/setup_env.sh
mkdir -p /home/Cornus/outputs/
cd /home/Cornus/src
make -j $1

