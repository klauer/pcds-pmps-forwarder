#!/bin/bash

# Set the IOC name
export IOC="ioc-pmpsForwarder"

# Setup the IOC user environment
# TODO: Change xxx as needed for your hutch
source /reg/d/iocCommon/All/xxx_env.sh

# For release
#cd $EPICS_SITE_TOP/ioc/xxx/pmpsForwarder/R0.1.0/iocBoot/ioc-pmpsForwarder

# Copy the archive file to iocData
$RUNUSER "cp ../../archive/$IOC.archive $IOC_DATA/$IOC/archive"

# Launch the IOC
$RUNUSER "$PROCSERV --logfile $IOC_DATA/$IOC/iocInfo/ioc.log --name $IOC 30001 ../../bin/rhel7-x86_64/pmpsForwarder st.cmd"
