function usage() {
    echo "usage: configChannels.sh"
    echo "-a    channel number - amplifier power"
    echo "-c    channel number - cavity power"
    echo "-l    LLRF_IOC_NAME (for PV prefix)"
    echo "-n    digitiser instance"
    echo "-p    channel number - preamplifier power"
    echo "-h    help"
}

options=":a:c:l:n:p:h"
while getopts "${options}" opts; do
    case "${opts}" in
        h) usage                    ;;
        a) chAmp=${OPTARG}          ;;
        c) chCav=${OPTARG}          ;;
        l) LLRF_IOC_NAME=${OPTARG}  ;;
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
[ ${#chAmp} -gt 0 ] && echo "dbLoadRecords(\$(E3_CMD_TOP)/alias.template, \"O=$LLRF_IOC_NAME$iNum:AI$chAmp, N=$LLRF_IOC_NAME:AmpPow\")" >> $fPath
[ ${#chCav} -gt 0 ] && echo "dbLoadRecords(\$(E3_CMD_TOP)/alias.template, \"O=$LLRF_IOC_NAME$iNum:AI$chCav, N=$LLRF_IOC_NAME:CavPow\")" >> $fPath
[ ${#chPreAmp} -gt 0 ] && echo "dbLoadRecords(\$(E3_CMD_TOP)/alias.template, \"O=$LLRF_IOC_NAME$iNum:AI$chPreAmp, N=$LLRF_IOC_NAME:PreAmpPow\")" >> $fPath


