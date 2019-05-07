#!../../bin/rhel7-x86_64/pmpsForwarder

< envPaths
epicsEnvSet("IOCNAME", "ioc-pmpsForwarder" )
epicsEnvSet("ENGINEER", "klauer" )
epicsEnvSet("PREFIX", "TST:PMPS:FWD:")
epicsEnvSet("LOCATION", "$(PREFIX)" )
epicsEnvSet("IOCSH_PS1", "$(IOCNAME)> " )

# For single PLC IOCs, modify only the following:
epicsEnvSet("PLC_HOSTNAME", "_PLC_HOSTNAME_")
epicsEnvSet("PLC_NETID",    "_PLC_HOSTNAME_.1.1")
epicsEnvSet("PLC_ADS_PORT", "851")
epicsEnvSet("PLC_PORT", "ADS_1")

cd "$(TOP)"

# Run common startup commands for linux soft IOC's
< /reg/d/iocCommon/All/pre_linux.cmd

# Register all support components
dbLoadDatabase("dbd/pmpsForwarder.dbd")
pmpsForwarder_registerRecordDeviceDriver(pdbbase)

# Connect to PLCs here:
adsAsynPortDriverConfigure("$(PLC_PORT)", "$(PLC_HOSTNAME)", "$(PLC_NETID)", "$(PLC_ADS_PORT)", 1000, 0, 0, 500, 1000, 1000, 0)
asynSetTraceMask("$(PLC_PORT)", -1, 0x41)
asynSetTraceIOMask("$(PLC_PORT)", -1, 6)
asynSetTraceInfoMask("$(PLC_PORT)", -1, 15)

# Load record instances
dbLoadRecords("db/heartbeat.db","P=TST:PMPS:FWD:,PORT=$(PLC_PORT)")
dbLoadRecords("db/pmps.db","P=TST:PMPS:FWD:, ALARM1=TST:PMPS:FWD:HB_Alarm, PORT=$(PLC_PORT)")
dbLoadRecords("","P=,PORT=$(PLC_PORT)")

dbLoadRecords("db/iocAdmin.db",	"P=TST:PMPS:FWD:,IOC=TST:PMPS:FWD:" )
dbLoadRecords("db/save_restoreStatus.db", "P=TST:PMPS:FWD:,IOC=TST:PMPS:FWD:" )

# Setup autosave
# set_savefile_path( "$(IOC_DATA)/$(IOC)/autosave" )
# set_requestfile_path( "$(TOP)/autosave" )
# save_restoreSet_status_prefix( "TST:PMPS:FWD::" )
# save_restoreSet_IncompleteSetsOk( 1 )
# save_restoreSet_DatedBackupFiles( 1 )
# set_pass0_restoreFile( "$(IOC).sav" )
# set_pass1_restoreFile( "$(IOC).sav" )

# Initialize the IOC and start processing records
iocInit()

seq(&HeartbeatMonitor, "HEARTBEAT_PV=$(PREFIX)Heartbeat, LATCH_ALARM_PV=$(PREFIX)HB_LatchAlarm, SKIPPED_BEAT_PV=$(PREFIX)HB_SkippedBeat.PROC, INITIALIZED_PV=$(PREFIX)HB_Initialized, HEART_RATE=0.1, BYGONES=2.0, MAX_SKIPPED=1")

# Start autosave backups
create_monitor_set( "$(IOC).req", 5, "" )

# All IOCs should dump some common info after initial startup.
# < /reg/d/iocCommon/All/post_linux.cmd
