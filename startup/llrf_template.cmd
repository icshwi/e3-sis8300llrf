# Timing Configuration
iocshLoad timing.iocsh

#######################
### LLRF CONTROLLER ###
#######################
epicsEnvSet("LLRF_PREFIX"     "$(SIS8300LLRF_PREFIX=LLRF)" )
epicsEnvSet("LLRF_SLOT"       "$(SIS8300LLRF_SLOT=<slot>)"      )
epicsEnvSet("LLRF_NOPULSETYPES" "$(SIS8300LLRF_NOPULSETYPES=1)")
epicsEnvSet("LLRF_PULSETYPE" "$(SIS8300LLRF_PULSETYPE=0)")

epicsEnvSet("LLRF_PORT",               "$(LLRF_PREFIX)")
epicsEnvSet("SP_SMNM_MAX"              "0x1000")
epicsEnvSet("FF_SMNM_MAX"              "0x10000")
epicsEnvSet("PIERR_SMNM_MAX"           "0x10000")
epicsEnvSet("AI_SMNM_MAX"              "0x60000")       
epicsEnvSet("AI_SMNM_DEFOPT"           "220000")       
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES" "1600000")

require sis8300llrf, 3.6.7
ndsSetTraceLevel 4
ndsCreateDevice "sis8300llrf", "$(LLRF_PORT)", "FILE=/dev/sis8300-$(LLRF_SLOT), NUM_PULSE_TYPES=$(LLRF_NOPULSETYPES)"

dbLoadRecords("sis8300llrf.db", "PREFIX=$(LLRF_PREFIX),ASYN_PORT=$(LLRF_PORT),NUM_PULSE_TYPES=$(LLRF_NOPULSETYPES),SP_SMNM_MAX=$(SP_SMNM_MAX), FF_SMNM_MAX=$(FF_SMNM_MAX), AI_NELM=$(AI_SMNM_MAX),PIERR_SMNM_MAX=$(PIERR_SMNM_MAX),SMNM_VAL=$(AI_SMNM_DEFOPT)")
dbLoadRecords("sis8300llrf-Main-ControlTable-CH.template", "PREFIX=$(LLRF_PREFIX), ASYN_PORT=$(LLRF_PORT), PULSE_TYPE=$(LLRF_PULSETYPE), CTRL_TABLE_TYPE=SP, CTRL_TABLE_CG_NAME=sp, TABLE_SMNM_MAX=$(SP_SMNM_MAX)")
dbLoadRecords("sis8300llrf-Main-ControlTable-CH.template", "PREFIX=$(LLRF_PREFIX), ASYN_PORT=$(LLRF_PORT), PULSE_TYPE=$(LLRF_PULSETYPE), CTRL_TABLE_TYPE=FF, CTRL_TABLE_CG_NAME=ff, TABLE_SMNM_MAX=$(FF_SMNM_MAX)")
dbLoadRecords("sis8300llrf-SpecOp.db", "PREFIX=$(LLRF_PREFIX), ASYN_PORT=$(LLRF_PORT), PULSE_TYPE=$(LLRF_PULSETYPE), FF_SMNM_MAX = 0x1000, SP_SMNM_MAX = 0x100000")
dbLoadRecords("sis8300llrf-Setup.db", "PREFIX=$(LLRF_PREFIX), ASYN_PORT=$(LLRF_PORT)")
dbLoadRecords("sis8300Register.db", "PREFIX=$(LLRF_PREFIX), ASYN_PORT=$(LLRF_PORT), REG_SCAN=2")
dbLoadRecords("sis8300noAO.db", "PREFIX=$(LLRF_PREFIX), ASYN_PORT=$(LLRF_PORT), AI_NELM=$(AI_SMNM_MAX)")
dbLoadRecords("sis8300llrf-Register.db", "PREFIX=$(LLRF_PREFIX), ASYN_PORT=$(LLRF_PORT), REG_SCAN=2")

