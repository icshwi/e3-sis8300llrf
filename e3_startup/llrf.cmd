#######################
### LLRF CONTROLLER ###
#######################
epicsEnvSet("LLRF_PREFIX"     "$(SIS8300LLRF_PREFIX=LLRF)" )
epicsEnvSet("LLRF_SLOT"       "$(SIS8300LLRF_SLOT=4)"      )
epicsEnvSet("LLRF_PULSETYPES" "$(SIS8300LLRF_PULSETYPES=1)")

epicsEnvSet("LLRF_PORT",               "$(LLRF_PREFIX)")
epicsEnvSet("SP_SMNM_MAX"              "0x1000")
epicsEnvSet("FF_SMNM_MAX"              "0x10000")
epicsEnvSet("PIERR_SMNM_MAX"           "0x10000")
epicsEnvSet("AI_SMNM_MAX"              "0x60000")       
epicsEnvSet("AI_SMNM_DEFOPT"           "220000")       
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES" "1600000")

require sis8300llrf, 3.4.3

ndsCreateDevice "sis8300llrf", "$(LLRF_PORT)", "FILE=/dev/sis8300-$(LLRF_SLOT), NUM_PULSE_TYPES=$(LLRF_PULSETYPES)"

//dbLoadRecords("m-epics-sis8300llrf/db/sis8300llrf.db", "PREFIX=$(LLRF_PREFIX),ASYN_PORT=$(LLRF_PORT),NUM_PULSE_TYPES=$(LLRF_PULSETYPES),SP_SMNM_MAX=$(SP_SMNM_MAX), FF_SMNM_MAX=$(FF_SMNM_MAX), AI_NELM=$(AI_SMNM_MAX),PIERR_SMNM_MAX=$(PIERR_SMNM_MAX),SMNM_VAL=$(AI_SMNM_DEFOPT)")
//dbLoadRecords("m-epics-sis8300llrf/db/sis8300llrf-Main-ControlTable-CH.template", "PREFIX=$(LLRF_PREFIX), ASYN_PORT=$(LLRF_PORT), PULSE_TYPE=$(PULSE_TYPE), CTRL_TABLE_TYPE=SP, CTRL_TABLE_CG_NAME=sp, TABLE_SMNM_MAX=$(SP_SMNM_MAX)")
//dbLoadRecords("m-epics-sis8300llrf/db/sis8300llrf-Main-ControlTable-CH.template", "PREFIX=$(LLRF_PREFIX), ASYN_PORT=$(LLRF_PORT), PULSE_TYPE=$(PULSE_TYPE), CTRL_TABLE_TYPE=FF, CTRL_TABLE_CG_NAME=ff, TABLE_SMNM_MAX=$(FF_SMNM_MAX)")
