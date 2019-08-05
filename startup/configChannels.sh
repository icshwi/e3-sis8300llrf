function usage() {
    echo "usage: configChannels.sh"
    echo "-a    channel number - amplifier power"
    echo "-c    channel number - cavity power"
    echo "-n    digitiser instance - as integer starting from 1"
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

if [ $# -lt 3 ]; then
    echo "Script requires at least input of digitiser instance and a channel number"
    usage
fi

installPath=/iocs/sis8300llrf
fPath=$installPath/config-aliasing$iNum.iocsh
# Populate IOC snippet for alias values
if [ -f $fPath ]; then
    rm $fPath
fi

# Populate iocsh snippet containing alias definitions.
echo "# Alias definitions for digitiser card number $iNum" > $fPath
template0="dbLoadRecords(\$(E3_CMD_TOP)/alias.template, \"O=$LLRF_IOC_NAME$iNum:AI"
if [ ${#chAmp} -gt 0 ]; then
    echo "$template0$chAmp, A=$LLRF_IOC_NAME:AmpPow\")" >> $fPath
    echo "$template0$chAmp-ATT, A=$LLRF_IOC_NAME:AmpPow-ATT\")" >> $fPath
    echo "$template0$chAmp-ATT-RBV, A=$LLRF_IOC_NAME:AmpPow-ATT-RBV\")" >> $fPath
fi
