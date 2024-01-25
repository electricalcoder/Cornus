#!/bin/bash
source $HOME/Cornus/tools/setup_env.sh
mkdir -p $HOME/Cornus/outputs/
cd $HOME/Cornus/src
make -j16 $1

