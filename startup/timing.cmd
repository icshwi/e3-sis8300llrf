require mrfioc2,2.2.0-rc5

epicsEnvSet("IOC" "TR")
epicsEnvSet("DEV1" "LLRF")

epicsEnvSet("MainEvtCODE"	"14")
epicsEnvSet("HeartbeatEvtCODE"	"122")
epicsEnvSet("ESSEvtClockRate"	"88.0525")

epicsEnvSet("Pulse_coming_event"	"15")
epicsEnvSet("Pulse_start_event"		"16")
epicsEnvSet("Pulse_end_event"		"17")

mrmEvrSetupPCI("$(DEV1)",	"08:00.0")
dbLoadRecords("evr-mtca-300u-ess.db","SYS=$(IOC), EVR=$(DEV1), D=$(DEV1), FEVT=$(ESSEvtClockRate)")
dbLoadRecords("evrevent.db","EN=$(IOC)-$(DEV1)-$(CODE), OBJ=$(DEV1), CODE=$(Pulse_coming_event), EVNT=$(Pulse_coming_event)")
dbLoadRecords("evrevent.db","EN=$(IOC)-$(DEV1)-$(CODE), OBJ=$(DEV1), CODE=$(Pulse_start_event), EVNT=$(Pulse_start_event)")
dbLoadRecords("evrevent.db","EN=$(IOC)-$(DEV1)-$(CODE), OBJ=$(DEV1), CODE=$(Pulse_end_event), EVNT=$(Pulse_end_event)")

# needed with software timestamp source without Real-Time thread scheduling
var evrMrmTimeNSOverflowThreshold 100000

iocInit()

# Get current time from system clock
dbpf $(IOC)-$(DEV1):TimeSrc-Sel 2

# Set delay compensation to 70 ns, needed to  avoid timestamp issue
dbpf $(IOC)-$(DEV1):DC-Tgt-SP 70

# Backplane trigger line configuration
dbpf $(IOC)-$(DEV1):DlyGen0-Evt-Trig0-SP $(Pulse_coming_event)
dbpf $(IOC)-$(DEV1):DlyGen0-Width-SP 1000 # time in micro-seconds
dbpf $(IOC)-$(DEV1):OutBack0-Src-SP 0 # trigger from delay generator 0 to RX17
dbpf $(IOC)-$(DEV1):OutFP0-Src-SP 0

dbpf $(IOC)-$(DEV1):DlyGen1-Evt-Trig0-SP $(Pulse_coming_event)
dbpf $(IOC)-$(DEV1):DlyGen1-Width-SP 1000 # time in micro-seconds
dbpf $(IOC)-$(DEV1):OutBack1-Src-SP 1 # trigger from delay generator 0 to TX17
dbpf $(IOC)-$(DEV1):OutFP1-Src-SP 1

dbpf $(IOC)-$(DEV1):DlyGen2-Evt-Trig0-SP $(Pulse_end_event)
dbpf $(IOC)-$(DEV1):DlyGen2-Width-SP 1000 # time in micro-seconds
dbpf $(IOC)-$(DEV1):OutBack2-Src-SP 2 # trigger from delay generator 0 to RX18
dbpf $(IOC)-$(DEV1):OutFP2-Src-SP 2

###For standalone mode only ###
# Set up the prescaler that will trigger the sequencer at 14 Hz
dbpf $(IOC)-$(DEV1):PS0-Dev-IP 6289424 # in standalone mode because real frequency from synthesiser is 88.05194802 MH\, otherwise 6289464

# Set up the sequencer
dbpf $(IOC)-$(DEV1):SoftSeq0-RunMode-Sel 0 # normal mode
dbpf $(IOC)-$(DEV1):SoftSeq0-TrigSrc-2-Sel 2 # prescaler 0
dbpf $(IOC)-$(DEV1):SoftSeq0-TsResolution-Sel 2 # us
dbpf $(IOC)-$(DEV1):SoftSeq0-Load-Cmd 1

system("/bin/sh /epics/iocs/sis8300llrf/tr-sequencer.sh $(IOC) $(DEV1)")
### \Standalone mode only ###
