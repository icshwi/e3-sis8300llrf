#!/bin/sh

#Prepare siteApp configuration for IOC instance specific configuration
siteApp=/iocs/sis8300llrf
mkdir -p $siteApp/log/
mkdir -p $siteApp/run/

cp $EPICS_SRC/e3-sis8300llrf/startup/llrf_template.iocsh $siteApp/llrf.iocsh
slots_fpga=$(ls /dev/sis8300-* | cut -f2 -d "-")
if [ ${#slots_fpga} -lt 1 ] ; then 
  echo "Could not find SIS8300 digitiser board."
  echo "Board slot must be manually configured in $siteApp/llrf.cmd"
  snippet="epicsEnvSet(\"LLRF_PREFIX\"     \"$LLRF_IOC_NAME\" ) \\\n \
epicsEnvSet(\"LLRF_SLOT\"       \"<slot>\"    ) \\\n \
iocshLoad $\(E3_CMD_TOP\)\/llrf.iocsh \\\n \
iocshLoad $\(E3_CMD_TOP\)\/aliasing1.iocsh \\\n"
  echo "snippet = $snippet"
  eval "sed -e $'s/<snippet>/$snippet/g' < $EPICS_SRC/e3-sis8300llrf/startup/llrf_template.cmd  > $siteApp/llrf.cmd" 
else
  # Start board enumeration from 1.
  i=1

  snippet=""
  for slot_fpga in $(ls /dev/sis8300-* | cut -f2 -d "-" | sort -n)
  do
    snippet="$snippet \\\n\
epicsEnvSet(\"LLRF_PREFIX\"     \"$LLRF_IOC_NAME$i\" ) \\\n \
epicsEnvSet(\"LLRF_SLOT\"       \"$slot_fpga\"    ) \\\n \
iocshLoad $\(E3_CMD_TOP\)\/llrf.iocsh \\\n \
iocshLoad $\(E3_CMD_TOP\)\/aliasing$i.iocsh \\\n"
    i=$(($i+1))
  done
    #Populate digitiser slot and IOC Name in startup script.
    eval "sed -e $'s/<snippet>/$snippet/g'\
        < $EPICS_SRC/e3-sis8300llrf/startup/llrf_template.cmd  > $siteApp/llrf.cmd" 

fi


#Timing configuration
# We check the EVR is available on PCIe to use in timing.iocsh snippet used to configure the EVR.
pcie_enumeration=$(lspci | grep Xilinx | cut -c1-7)
if [ ${#pcie_enumeration} != 7 ] ; then
  echo "Could not find Timing Event Receiver on PCIexpress bus."
  echo "Therefore no timing configuration created."
  echo "# no timing configuration as no EVR detected on PCIe bus." > $siteApp/timing.iocsh 
else
  eval "sed -e 's/<B:D.F>/$pcie_enumeration/' -e 's/<LLRF_IOC_NAME>/$LLRF_IOC_NAME/' < $EPICS_SRC/e3-sis8300llrf/startup/timing_template.iocsh" > "/iocs/sis8300llrf/timing.iocsh"
  cp $EPICS_SRC/e3-sis8300llrf/startup/tr-sequencer.sh $siteApp/tr-sequencer.sh
fi

# Alias template
cp $EPICS_SRC/e3-sis8300llrf/startup/alias.template $siteApp/alias.template
