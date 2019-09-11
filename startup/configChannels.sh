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


{
read
while IFS=, read -r ch pv_name desc
do
    ch=$(echo $ch |  sed -e 's/^[ \t]*//')
    pv_name=$(echo $pv_name |  sed -e 's/^[ \t]*//')
    desc=$(echo $desc |  sed -e 's/^[ \t]*//')
    if [ ${#desc} -gt 41 ]; then
        echo "Warning: Description truncated to char[41] - ${desc:0:40}"
        desc=${desc:0:40}
    fi

    # If alias is the same as channel, doesn't set alias
    if [ $pv_name != "AI$ch" ]; then
        echo "# Board $iNum, Channel $ch = $pv_name" >> $fPath
        oPrefix="$template0$ch"
        aPrefix="$LLRF_IOC_NAME:$pv_name"
        
        # set aliases
        echo "$oPrefix, A=$aPrefix\")" >> $fPath
        echo "$oPrefix-ATT, A=$aPrefix-ATT\")" >> $fPath
        echo "$oPrefix-ATT-RBV, A=$aPrefix-ATT-RBV\")" >> $fPath
        echo "$oPrefix-DECF, A=$aPrefix-DECF\")" >> $fPath
        echo "$oPrefix-DECF-RBV, A=$aPrefix-DECF-RBV\")" >> $fPath
        echo "$oPrefix-DECO, A=$aPrefix-DECO\")" >> $fPath
        echo "$oPrefix-DECO-RBV, A=$aPrefix-DECO-RBV\")" >> $fPath
        echo "$oPrefix-FileName, A=$aPrefix-FileName\")" >> $fPath
        echo "$oPrefix-Slope, A=$aPrefix-Slope\")" >> $fPath
        echo "$oPrefix-Offset, A=$aPrefix-Offset\")" >> $fPath
        echo "$oPrefix-InputValues, A=$aPrefix-InputValues\")" >> $fPath
        echo "$oPrefix-DigitisedValues, A=$aPrefix-DigitisedValues\")" >> $fPath
        echo "$oPrefix-FittedLine, A=$aPrefix-FittedLine\")" >> $fPath
    fi

    # set descriptions
    echo "$template1\"A=$LLRF_IOC_NAME$iNum:AI$ch, D=$desc\")" >> $fPathDesc

done
} < $confFile

