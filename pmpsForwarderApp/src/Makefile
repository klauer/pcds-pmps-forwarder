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

# pmpsForwarder.dbd will be made up from these files:
pmpsForwarder_DBD += base.dbd
pmpsForwarder_DBD += iocAdmin.dbd
pmpsForwarder_DBD += asSupport.dbd
pmpsForwarder_DBD += ads.dbd
pmpsForwarder_DBD += asyn.dbd
pmpsForwarder_DBD += drvAsynIPPort.dbd

ifneq (,$(findstring /,$(CALC)))
  pmpsForwarder_DBD += calcSupport.dbd
  pmpsForwarder_LIBS += calc
endif

ifneq (,$(findstring /,$(ADS)))
  pmpsForwarder_LIBS += ads
  pmpsForwarder_DBD  += ads.dbd
endif

ifneq (,$(findstring /,$(MOTOR)))
  pmpsForwarder_DBD += motorSupport.dbd
  pmpsForwarder_DBD += devSoftMotor.dbd
  pmpsForwarder_DBD += EthercatMcSupport.dbd

  pmpsForwarder_LIBS += motor
  pmpsForwarder_LIBS += softMotor
  pmpsForwarder_LIBS += EthercatMcSupport
endif

# pmpsForwarder_registerRecordDeviceDriver.cpp will be created from pmpsForwarder.dbd
pmpsForwarder_SRCS += pmpsForwarder_registerRecordDeviceDriver.cpp
pmpsForwarder_SRCS_DEFAULT += pmpsForwarderMain.cpp

pmpsForwarder_LIBS += devIocStats
pmpsForwarder_LIBS += asyn
pmpsForwarder_LIBS += autosave
pmpsForwarder_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE
