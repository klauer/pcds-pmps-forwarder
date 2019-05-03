#!../../bin/rhel7-x8_64/$$APPNAME

epicsEnvSet("IOCNAME", "$$IOCNAME")
epicsEnvSet("ENGINEER", "$$ENGINEER" )
epicsEnvSet("LOCATION", "$$LOCATION" )
epicsEnvSet("IOCSH_PS1", "$(IOCNAME)> " )
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", "$$IF(MAX_ARRAY,$$MAX_ARRAY,8000000)" )
epicsEnvSet("STREAM_PROTOCOL_PATH", "db" )
epicsEnvSet("IOC_PV", "$$IOC_PV")
epicsEnvSet("IOCTOP", "$$IOCTOP")

< $(IOCTOP)/iocBoot/ioc/envPaths
< envPaths

epicsEnvSet("TOP", "$$TOP")
cd( "$(IOCTOP)" )

# Run common startup commands for linux soft IOC's
< /reg/d/iocCommon/All/pre_linux.cmd

# Load EPICS database definition
dbLoadDatabase("dbd/.dbd",0,0)

# Register all support components
_registerRecordDeviceDriver(pdbbase)

$$LOOP(EXTRA)
$$IF(INITTIME)
$$INCLUDE(NAME)
$$ENDIF(INITTIME)
$$ENDLOOP(EXTRA)

## Load EPICS records
$$LOOP(PLC)
adsAsynPortDriverConfigure("$$(NAME)", "$$(HOSTNAME)", "$$(NETID)", "$$(ADS_PORT)", 1000, 0, 0, 500, 1000, 1000, 0)
asynSetTraceMask("$$(NAME)", -1, 0x41)
asynSetTraceIOMask("$$(NAME)", -1, 6)
asynSetTraceInfoMask("$$(NAME)", -1, 15)
dbLoadRecords("db/plc_$$(NAME).db", "IOC=$(IOC_PV),PORT=$$(NAME),ADS_PORT=$$(ADS_PORT)" )
$$ENDLOOP(PLC)

# Enable sleep() calls as needed to diagnose startup errors
# epicsThreadSleep( 5.0 )

## Load EPICS records
dbLoadRecords( "db/iocAdmin.db",		   "IOC=$(IOC_PV)" )
dbLoadRecords( "db/save_restoreStatus.db", "IOC=$(IOC_PV)" )

# Setup autosave
set_savefile_path( "$(IOC_DATA)/$(IOC)/autosave" )
set_requestfile_path( "$(TOP)/autosave" )
save_restoreSet_status_prefix( "$(IOC_PV):" )

save_restoreSet_IncompleteSetsOk( 1 )
save_restoreSet_DatedBackupFiles( 1 )

set_pass0_restoreFile( "$(IOCNAME).sav" )
set_pass1_restoreFile( "$(IOCNAME).sav" )

# Initialize the IOC and start processing records
iocInit()

# Start autosave backups
create_monitor_set( "$(IOCNAME).req", 5, "IOC=$(IOC_PV)")

$$LOOP(EXTRA)
$$IF(FINISHTIME)
$$INCLUDE(NAME)
$$ENDIF(FINISHTIME)
$$ENDLOOP(EXTRA)

# Run the post startup script
< /reg/d/iocCommon/All/post_linux.cmd
