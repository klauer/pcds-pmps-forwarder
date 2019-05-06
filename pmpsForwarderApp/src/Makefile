TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#=============================
# Build an ioc application
PROD_IOC = pmpsForwarder

# pmpsForwarder.dbd will be created and installed
DBD += pmpsForwarder.dbd

pmpsForwarder_DBD += base.dbd
# Libraries for all IOCs - ioc stats and autosave
pmpsForwarder_DBD += iocAdmin.dbd
pmpsForwarder_DBD += asSupport.dbd
# Basic useful records - calc
pmpsForwarder_DBD += calcSupport.dbd
# ADS / ethercat motor (TODO remove)
pmpsForwarder_DBD += ads.dbd
pmpsForwarder_DBD += asyn.dbd
pmpsForwarder_DBD += drvAsynIPPort.dbd
pmpsForwarder_DBD += motorSupport.dbd
pmpsForwarder_DBD += devSoftMotor.dbd
pmpsForwarder_DBD += EthercatMcSupport.dbd

# pmpsForwarder_registerRecordDeviceDriver.cpp will be created from pmpsForwarder.dbd
pmpsForwarder_SRCS += pmpsForwarder_registerRecordDeviceDriver.cpp
pmpsForwarder_SRCS_DEFAULT += pmpsForwarderMain.cpp

pmpsForwarder_LIBS += devIocStats
pmpsForwarder_LIBS += autosave
pmpsForwarder_LIBS += ads
pmpsForwarder_LIBS += motor
pmpsForwarder_LIBS += softMotor
pmpsForwarder_LIBS += EthercatMcSupport
pmpsForwarder_LIBS += calc sscan
pmpsForwarder_LIBS += asyn
pmpsForwarder_LIBS += seq pv
pmpsForwarder_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE
