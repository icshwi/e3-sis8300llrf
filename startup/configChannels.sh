#!/bin/bash
if [ $# -ne 2 ]; then
    echo "usage: configChannels.sh <digitiser instance> <config input file>"
    echo "There is an example for config input file: configChannels.input"
    exit
fi

installPath=/iocs/sis8300llrf

if [ ! -d $installPath ]; then
    echo "Folder $installPath not found!"
    exit
fi

if [ ! -w $installPath ]; then
    echo "You cannot write on $installPath !"
    exit
fi


iNum=$1
confFile=$2


fPath=$installPath/config-aliasing$iNum.iocsh
fPathDesc=$installPath/config-desc$iNum.iocsh
# Populate IOC snippet for alias values
if [ -f $fPath ]; then
    rm $fPath
fi

if [ -f $fPathDesc ]; then
    rm $fPathDesc
fi

# Populate iocsh snippet containing alias definitions.
echo "# Alias definitions for digitiser card number $iNum" > $fPath
template0="dbLoadRecords(\$(E3_CMD_TOP)/alias.template, \"O=$LLRF_IOC_NAME$iNum:AI"
template1="dbLoadRecords(\$(E3_CMD_TOP)/desc.template, "


i=0
cat $confFile | while read line
do
    pv_name=$(echo $line | cut -f 1 -d ,)
    desc=$(echo $line | cut -f 2 -d , | sed -e 's/^[ \t]*//')
    if [ ${#desc} -gt 41 ]; then
        echo "Warning: Description truncated to char[41] - ${desc:0:40}"
        desc=${desc:0:40}
    fi

    # set aliases
    echo "$template0$i, A=$LLRF_IOC_NAME$iNum:$pv_name\")" >> $fPath
    echo "$template0$i-ATT, A=$LLRF_IOC_NAME$iNum:$pv_name-ATT\")" >> $fPath
    echo "$template0$i-ATT-RBV, A=$LLRF_IOC_NAME$iNum:$pv_name-ATT-RBV\")" >> $fPath
    echo "$template0$i-DECF, A=$LLRF_IOC_NAME$iNum:$pv_name-DECF\")" >> $fPath
    echo "$template0$i-DECF-RBV, A=$LLRF_IOC_NAME$iNum:$pv_name-DECF-RBV\")" >> $fPath
    echo "$template0$i-DECO, A=$LLRF_IOC_NAME$iNum:$pv_name-DECO\")" >> $fPath
    echo "$template0$i-DECO-RBV, A=$LLRF_IOC_NAME$iNum:$pv_name-DECO-RBV\")" >> $fPath
    echo "$template0$i-FileName, A=$LLRF_IOC_NAME$iNum:$pv_name-FileName\")" >> $fPath
    echo "$template0$i-Slope, A=$LLRF_IOC_NAME$iNum:$pv_name-Slope\")" >> $fPath
    echo "$template0$i-Offset, A=$LLRF_IOC_NAME$iNum:$pv_name-Offset\")" >> $fPath
    echo "$template0$i-InputValues, A=$LLRF_IOC_NAME$iNum:$pv_name-InputValues\")" >> $fPath
    echo "$template0$i-DigitisedValues, A=$LLRF_IOC_NAME$iNum:$pv_name-DigitisedValues\")" >> $fPath
    echo "$template0$i-FittedLine, A=$LLRF_IOC_NAME$iNum:$pv_name-FittedLine\")" >> $fPath

    # set descriptions
    echo "$template1\"A=$LLRF_IOC_NAME$iNum:$pv_name, D=$desc\")" >> $fPathDesc

    i=$(($i+1))
done


