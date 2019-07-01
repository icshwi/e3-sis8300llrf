if [ $# -lt 1 ] ; then                              
    echo "usage: sh test1.sh <SIS8300 slot>"
    echo "e.g. sh test1.sh 6"                  
    exit                                            
fi          

slot=$1

path=$(pwd)/$(dirname $0)
# Print module versions
echo "*** Module versions"
pv_mods=`cat /epics/iocs/sis8300llrf/REQMODs.list | grep MODULES`
pv_vers=`cat /epics/iocs/sis8300llrf/REQMODs.list | grep VERSIONS`
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
run "state_change RESET RESETTING"
run "state_change OFF"
run "state_change INIT"
run "state_change ON"
run "state_change RESET RESETTING"
run "state_change INIT"

echo "*** VM Output"
echo 'Enable VM'
caput $LLRF_IOC_NAME:VMENBL 1 > /dev/null
run "check 0x700 $(sis8300drv_reg /dev/sis8300-$slot 0x12F) 'Test on Enable VM'"

echo 'Disable VM'
caput $LLRF_IOC_NAME:VMENBL 0 > /dev/null
run "check 0x600 $(sis8300drv_reg /dev/sis8300-$slot 0x12F) 'Test on Disable VM'"

echo '*** Attenuation Parameters'
echo 'Test in INIT state'

run "state_change 'RESET' 'RESETTING'"
run "state_change 'INIT'"

# Use only integers for testing of attenuation range 1-31
# Note this excludes fractional attenuation values in the testing but for now the simplicity with worth the limited functionality testing.

for i in `seq 0 8`
do 
	run "set_att $slot $i"
done

echo 'Test attenuation setting in ON state'

run "state_change 'RESET' 'RESETTING'"
run "state_change 'INIT'"
run "state_change 'ON'"

attVal=$(( $RANDOM % 30 + 1 ))
for i in `seq 0 8`;
do
	run "set_att $slot $i"
done

echo 'Revert to INIT state'
run "state_change 'RESET' 'RESETTING'"
run "state_change 'INIT'"

echo '*** Pulse'

run "state_change 'RESET' 'RESETTING'"
run "state_change 'INIT'"
run "state_change 'ON'"

echo 'Simulating backplane triggers to FPGA for pulse_coming, pulse_start and pulse_end.'

for i in `seq 1 50`
do
    echo "Beam Pulse $i"
    sis8300drv_reg /dev/sis8300-$slot 0x404 -w 0x20
    sis8300drv_reg /dev/sis8300-$slot 0x404 -w 0x40
    sis8300drv_reg /dev/sis8300-$slot 0x404 -w 0x80
    usleep 100000
done

result="$(caget -t $LLRF_IOC_NAME:PULSEDONECNT)"
run "check $result 50 'Test simulating backplane triggers'"

echo 'Revert to INIT state'
run "state_change 'RESET' 'RESETTING'"
run "state_change 'INIT'"
