# IOC instance Makefile
# Generates envPaths and expands the instance
# specific substitution files.

TOP = ../..
include $(TOP)/configure/CONFIG
ARCH = rhel7-x86_64
TARGETS = envPaths

# Make sure these archive files are fully expanded
USR_ARCHIVEFLAGS += -V

#----------------------------------------------------
# Create and install IOC archive file
#
ARCHIVE += ioc-pmpsForwarder.archive

#----------------------------------------------------
# Create and install IOC autosave file
#
REQ += ioc-pmpsForwarder.req

include $(TOP)/configure/RULES
include $(TOP)/configure/RULES.ioc-targets
