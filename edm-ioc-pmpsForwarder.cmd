#! /bin/bash

# Setup edm environment
source /reg/g/pcds/setup/epicsenv-3.14.12.sh

edm -x -m "IOC=TST:PMPS:FWD:" -eolc pmpsForwarderScreens/pmpsForwarder.edl &
