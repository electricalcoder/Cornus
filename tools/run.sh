#!/bin/bash
source setup_env.sh
cd $HOME/Cornus/src
mkdir -p ${HOME}/Cornus/outputs
./rundb $1
