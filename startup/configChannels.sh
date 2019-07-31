function usage() {
    echo "usage: configChannels.sh"
    echo "-a    channel number - amplifier power"
    echo "-c    channel number - cavity power"
    echo "-n    digitiser instance"
    echo "-p    channel number - preamplifier power"
    echo "-h    help"
}

options=":a:c:n:p:h"
while getopts "${options}" opts; do
    case "${opts}" in
        h) usage                    ;;
        a) chAmp=${OPTARG}          ;;
        c) chCav=${OPTARG}          ;;
        n) iNum=${OPTARG}           ;; 
        p) chPreAmp=${OPTARG}       ;;
    esac
done

installPath=/iocs/sis8300llrf
fPath=$installPath/aliasing$iNum.iocsh
# Populate IOC snippet for alias values
if [ -f $fPath ]; then
    rm $fPath
fi

# Populate iocsh snippet containing alias definitions.
echo "# Alias definitions for digitiser card number $iNum" > $fPath
if [ ${#chAmp} -gt 0 ]; then
    echo "dbLoadRecords(\$(E3_CMD_TOP)/alias.template, \"O=$LLRF_IOC_NAME$iNum:AI$chAmp, A=$LLRF_IOC_NAME:AmpPow\")" >> $fPath
    echo "dbLoadRecords(\$(E3_CMD_TOP)/alias.template, \"O=$LLRF_IOC_NAME$iNum:AI$chAmp-ATT, A=$LLRF_IOC_NAME:AmpPow-ATT\")" >> $fPath
    echo "dbLoadRecords(\$(E3_CMD_TOP)/alias.template, \"O=$LLRF_IOC_NAME$iNum:AI$chAmp-ATT-RBV, A=$LLRF_IOC_NAME:AmpPow-ATT-RBV\")" >> $fPath
fi
