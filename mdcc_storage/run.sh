#!/bin/bash
cd $HOME/Sundial-Private/tools || exit
source setup_env.sh
cd $HOME/Sundial-Private/mdcc_storage || exit
./rundb $1