if [ $# -lt 2 ] ; then                              
    echo "usage: sh test1.sh <system> <SIS8300 slot>"
    echo "e.g. sh test1.sh LLRF-LION 6"                  
    exit                                            
fi          

# Print module versions
echo "*** Module versions"
pv_mods=`cat /epics/iocs/sis8300llrf/REQMODs.list | grep MODULES`
pv_vers=`cat /epics/iocs/sis8300llrf/REQMODs.list | grep VERSIONS`
n=`caget -t $pv_mods | cut -d ' ' -f 1`
for (( i=2; i <= $n+1; i++ ))
do
    mod=`caget -t $pv_mods | cut -d ' ' -f $i`
    ver=`caget -t $pv_vers | cut -d ' ' -f $i`
    echo $mod - $ver
done

llrf_prefix=$1

test() {
	[ "$1" = "$2" ] && echo "Pass" || echo "***Fail: result = $2***"
}

state_change() {
	echo "Go to state $1"
	eval "caput -S $llrf_prefix:MSGS $1 >/dev/null"
	usleep 500000
	if [ $# -eq 2 ]; then 
		test $2 "$(caget -t $llrf_prefix)"
	else
		test $1 "$(caget -t $llrf_prefix)"
	fi
}

set_att() {
	attVal=$(( 1 + (RANDOM % 30  / (1 + $1 / 8)) ))
	state=$(( $attVal * 2 * (1 + $1 / 8) ))
	echo "Ch $1 - setting attenuation to $attVal"
	caput $llrf_prefix:AI$1-ATT $attVal > /dev/null
	# 4-byte registers 0xF82, 0xF83 and 0xF84 hold the values with one byte offsets between values
	reg="0xF8$(( 2 + $i / 4 ))"
	result="$(sis8300drv_reg /dev/sis8300-$2 $reg)"
	rshift=$(( $1 % 4 * 8))
	result=$(( ($result >> $rshift) & 0x000000FF))
	usleep 500000
	test $state $result
}

echo '*** State Machine'

state_change RESET RESETTING
state_change OFF
state_change INIT
state_change ON
state_change RESET RESETTING
state_change INIT

echo "*** VM Output"
echo 'Enable VM'
caput $llrf_prefix:VMENBL 1 > /dev/null
test 0x700 "$(sis8300drv_reg /dev/sis8300-$2 0x12F)"

echo 'Disable VM'
caput $llrf_prefix:VMENBL 0 > /dev/null
test 0x600 "$(sis8300drv_reg /dev/sis8300-$2 0x12F)"

echo '*** Attenuation Parameters'
echo 'Test in INIT state'

state_change 'RESET' 'RESETTING'
state_change 'INIT'

# Use only integers for testing of attenuation range 1-31
# Note this excludes fractional attenuation values in the testing but for now the simplicity with worth the limited functionality testing.

attVal=$(( $RANDOM % 30 + 1 ))
for i in `seq 0 8`
do 
	set_att $i $2
done

echo 'Test attenuation setting in ON state'

state_change 'RESET' 'RESETTING'
state_change 'INIT'
state_change 'ON'

attVal=$(( $RANDOM % 30 + 1 ))
for i in `seq 0 8`;
do
	set_att $i $2
done

echo 'Revert to INIT state'
state_change 'RESET' 'RESETTING'
state_change 'INIT'

echo '*** Pulse'

state_change 'RESET' 'RESETTING'
state_change 'INIT'
state_change 'ON'

echo 'Simulating backplane triggers to FPGA for pulse_coming, pulse_start and pulse_end.'
sis8300drv_reg /dev/sis8300-$2 0x404 -w 0x20
sis8300drv_reg /dev/sis8300-$2 0x404 -w 0x40
sis8300drv_reg /dev/sis8300-$2 0x404 -w 0x80
result="$(caget -t $llrf_prefix:PULSEDONECNT)"
test $result 1

echo 'Revert to INIT state'
state_change 'RESET' 'RESETTING'
state_change 'INIT'
