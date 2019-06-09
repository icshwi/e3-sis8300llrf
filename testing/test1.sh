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
echo '*** State Machine'

state='ON'
echo "Go to $state"
caput $llrf_prefix $state > /dev/null
result="$(caget -t $llrf_prefix)"
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

state='RESETTING'
echo "Go to $state"
caput $llrf_prefix $state > /dev/null
result="$(caget -t $llrf_prefix)"
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

state='INIT'
echo "Go to $state"
caput $llrf_prefix $state > /dev/null
result="$(caget -t $llrf_prefix)"
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

state='ON'
echo "Go to $state"
caput $llrf_prefix $state > /dev/null
result="$(caget -t $llrf_prefix)"
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

echo 'Enable VM'
state=0x700
caput $llrf_prefix:VMENBL 1 > /dev/null
result="$(sis8300drv_reg /dev/sis8300-$2 0x12F)"
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

echo 'Disable VM'
state=0x600
caput $llrf_prefix:VMENBL 0 > /dev/null
result="$(sis8300drv_reg /dev/sis8300-$2 0x12F)"
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

echo 'Test attenuator values'
attVal=$(( $RANDOM % 31 ))
state=$(( $attVal * 2 ))

echo "AI0 attenuator set to $attVal"
caput $llrf_prefix:AI0-ATT $attVal > /dev/null
result="$(sis8300drv_reg /dev/sis8300-$2 0xF82)"
result=$(($result & 0x000000FF))
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

echo "AI1 attenuator set to $attVal"
caput $llrf_prefix:AI1-ATT $attVal > /dev/null
result="$(sis8300drv_reg /dev/sis8300-$2 0xF82)"
result=$(($result >> 8 & 0x000000FF))
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

echo "AI2 attenuator set to $attVal"
caput $llrf_prefix:AI2-ATT $attVal > /dev/null
result="$(sis8300drv_reg /dev/sis8300-$2 0xF82)"
result=$(($result >> 16 & 0x000000FF))
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

echo "AI3 attenuator set to $attVal"
caput $llrf_prefix:AI3-ATT $attVal > /dev/null
result="$(sis8300drv_reg /dev/sis8300-$2 0xF82)"
result=$(($result >> 24 & 0x000000FF))
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

echo "AI4 attenuator set to $attVal"
caput $llrf_prefix:AI4-ATT $attVal > /dev/null
result="$(sis8300drv_reg /dev/sis8300-$2 0xF83)"
result=$(($result & 0x000000FF))
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

echo "AI5 attenuator set to $attVal"
caput $llrf_prefix:AI5-ATT $attVal > /dev/null
result="$(sis8300drv_reg /dev/sis8300-$2 0xF83)"
result=$(($result >> 8 & 0x000000FF))
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

echo "AI6 attenuator set to $attVal"
caput $llrf_prefix:AI6-ATT $attVal > /dev/null
result="$(sis8300drv_reg /dev/sis8300-$2 0xF83)"
result=$(($result >> 16 & 0x000000FF))
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

echo "AI7 attenuator set to $attVal"
caput $llrf_prefix:AI7-ATT $attVal > /dev/null
result="$(sis8300drv_reg /dev/sis8300-$2 0xF83)"
result=$(($result >> 24 & 0x000000FF))
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"

attVal=$(( RANDOM % 15 ))
state=$(( attVal * 4 ))
echo "AI8 attenuator set to $attVal"
caput $llrf_prefix:AI8-ATT $attVal > /dev/null
result="$(sis8300drv_reg /dev/sis8300-$2 0xF84)"
result=$(($result & 0x000000FF))
[ "$result" = "$state" ] && echo "Pass" || echo "***FAIL!!!***"
