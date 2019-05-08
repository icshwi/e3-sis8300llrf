# $1 is $(IOC) macro
# $2 is $(DEV1) macro
caput $1-$2:PS0-Div-SP 6289424 # in standalone mode because real frequency from synthesiser is 88.06194802 MHz, otherwise 6289464

# Configure the sequencer
caput $1-$2:SoftSeq0-RunMode-Sel 0 # normal mode
caput $1-$2:SoftSeq0-TrigSrc-2-Sel 2 # prescaler 0
caput $1-$2:SoftSeq0-TsResolution-Sel 2
caput $1-$2:SoftSeq0-Load-Cmd 1
caput $1-$2:SoftSeq0-Enable-Cmd 1

caput -a $1-$2:SoftSeq0-EvtCode-SP 5 14 15 16 17 127 >/dev/null
caput -a $1-$2:SoftSeq0-Timestamp-SP 5 0 10 310 3170 3180 >/dev/null
caput $1-$2:SoftSeq0-Commit-Cmd 1 >/dev/null
