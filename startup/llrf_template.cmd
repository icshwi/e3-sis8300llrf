# Timing Configuration
iocshLoad $(E3_CMD_TOP)/timing.iocsh

epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES" "8388624")
require sis8300llrf, 3.10.2
ndsSetTraceLevel 5

<snippet>

afterInit("dbgrep REQMOD* > '$(E3_CMD_TOP)/REQMODs.list'")

