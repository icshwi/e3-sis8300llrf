if [ $# -lt 2 ] ; then                              
    echo "usage: sh test1.sh <LLRF INSTANCE> <SIS8300 slot>"
    echo "e.g. sh test1.sh LLRF1 6"                  
    exit                                            
fi          

LLRF_INSTANCE=$1
slot=$2

path=$(pwd)/$(dirname $0)
# Print module versions
echo "*** Module versions"
pv_mods=`cat /iocs/sis8300llrf/REQMODs.list | grep MODULES`
pv_vers=`cat /iocs/sis8300llrf/REQMODs.list | grep VERSIONS`
n=`caget -t $pv_mods | cut -d ' ' -f 1`
for (( i=2; i<= $n+1; i++ ))
do
    mod=`caget -t $pv_mods | cut -d ' ' -f $i`
    ver=`caget -t $pv_vers | cut -d ' ' -f $i`
    echo $mod - $ver
done

run() {
    eval "$path/$1"
}

echo '*** State Machine'
run "state_change $LLRF_INSTANCE RESET"
run "state_change $LLRF_INSTANCE OFF"
run "state_change $LLRF_INSTANCE INIT"
run "state_change $LLRF_INSTANCE ON"
run "state_change $LLRF_INSTANCE RESET"
run "state_change $LLRF_INSTANCE INIT"

echo "*** VM Output"
echo 'Enable VM'
caput $LLRF_INSTANCE:VMENBL 1 > /dev/null
run "check 0x700 $(sis8300drv_reg /dev/sis8300-$slot 0x12F) 'Test on Enable VM'"

echo 'Disable VM'
caput $LLRF_INSTANCE:VMENBL 0 > /dev/null
run "check 0x600 $(sis8300drv_reg /dev/sis8300-$slot 0x12F) 'Test on Disable VM'"

echo '*** Attenuation Parameters'
echo 'Test in INIT state'

run "state_change $LLRF_INSTANCE RESET"
run "state_change $LLRF_INSTANCE INIT"

# Use only integers for testing of attenuation range 1-30 (for channels 0-7) and 1-15 (for channel 8)
# Note this excludes fractional attenuation values in the testing but for now the simplicity with worth the limited functionality testing.

for i in `seq 0 8`
do 
    attVal=$(($RANDOM % 31 / (1 + $i / 8) ))
	run "set_att $LLRF_INSTANCE $slot $i $attVal"
done

echo 'Test attenuation setting in ON state'

run "state_change $LLRF_INSTANCE RESET"
run "state_change $LLRF_INSTANCE INIT"
run "state_change $LLRF_INSTANCE ON"

for i in `seq 0 8`;
do
    attVal=$(($RANDOM % 31 / (1 + $i / 8) ))
	run "set_att $LLRF_INSTANCE $slot $i $attVal"
done

echo 'Test attenuation on state RESET and after transition from RESET'
attVal=10
for i in `seq 0 8`;
do
	run "set_att $LLRF_INSTANCE $slot $i $attVal"
done
run "state_change $LLRF_INSTANCE RESET"
echo "Change attenuation on channel 0 to 11"
caput $LLRF_INSTANCE:AI0-ATT 11 > /dev/null

result1="$(sis8300drv_reg /dev/sis8300-$slot 0xF82)"
result2="$(sis8300drv_reg /dev/sis8300-$slot 0xF83)"
result3="$(sis8300drv_reg /dev/sis8300-$slot 0xF84)"

run "check 0x14141414 $result1 'Test attenuator on transition case'"
run "check 0x14141414 $result2 'Test attenuator on transition case'"
run "check 0x28 $result3 'Test attenuator on transition case'"

run "state_change $LLRF_INSTANCE INIT"
result1="$(sis8300drv_reg /dev/sis8300-$slot 0xF82)"
result2="$(sis8300drv_reg /dev/sis8300-$slot 0xF83)"
result3="$(sis8300drv_reg /dev/sis8300-$slot 0xF84)"

run "check 0x14141416 $result1 'Test attenuator on transition case'"
run "check 0x14141414 $result2 'Test attenuator on transition case'"
run "check 0x28 $result3 'Test attenuator on transition case'"


echo '*** Pulse'

run "state_change $LLRF_INSTANCE RESET"
run "state_change $LLRF_INSTANCE INIT"
run "state_change $LLRF_INSTANCE ON"

echo 'Simulating backplane triggers to FPGA for pulse_coming, pulse_start and pulse_end.'

for i in `seq 1 50`
do
    echo "Beam Pulse $i"
    sis8300drv_reg /dev/sis8300-$slot 0x404 -w 0x20
    sis8300drv_reg /dev/sis8300-$slot 0x404 -w 0x40
    sis8300drv_reg /dev/sis8300-$slot 0x404 -w 0x80
    usleep 100000
done

result="$(caget -t $LLRF_INSTANCE:PULSEDONECNT)"
run "check $result 50 'Test simulating backplane triggers'"

run "state_change $LLRF_INSTANCE RESET"
run "state_change $LLRF_INSTANCE INIT"
run "state_change $LLRF_INSTANCE ON"

for i in `seq 1 49`
do
    echo "Beam Pulse $i"
    sis8300drv_reg /dev/sis8300-$slot 0x404 -w 0x20
    sis8300drv_reg /dev/sis8300-$slot 0x404 -w 0x40
    sis8300drv_reg /dev/sis8300-$slot 0x404 -w 0x80
    usleep 100000
done

result="$(caget -t $LLRF_INSTANCE:PULSEDONECNT)"
run "check $result 49 'Test simulating backplane triggers'"

echo 'Revert to INIT state'
run "state_change $LLRF_INSTANCE RESET"
run "state_change $LLRF_INSTANCE INIT"

echo '*** Calibration'
for (( i=0; i<= 9; i++ ))
do
    echo "*Calibration test for channel $i"
    python3 $EPICS_SRC/e3-scaling/scaling/tests/test.py $LLRF_INSTANCE AI$i
done


