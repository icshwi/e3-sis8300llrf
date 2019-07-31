#!/bin/sh
if [ "$EUID" -ne 0 ] ; then
  echo "Deployment script must be run with root priviledges, exiting..." 
  exit
fi

if [[ $# -gt 0 ]] ; then
  EPICS_SRC=$1
  EPICS_BASE=$2
  E3_REQUIRE_VERSION=$3
  LLRF_IOC_NAME=$4
else
  echo "Usage: sudo deployServiceIOC.sh <e3 source directory> <epics base directory> <epics require version> <LLRF_IOC_NAME>"
  echo "sudo deployServiceIOC.sh $EPICS_SRC $EPICS_BASE $E3_REQUIRE_VERSION $LLRF_IOC_NAME"
  exit
fi

hostName=$(hostname)
serviceName=/etc/systemd/system/ioc@llrf.service
serviceNameGit=$EPICS_SRC/e3-sis8300llrf/startup/ioc@llrf.service
#Prepare service and enable

#Get EPICS base version and require version
ver_base=$(echo $EPICS_BASE | cut -c13-18)
eval "sed -e 's/icslab-llrf/$hostName/'\
	-e 's/<epics_base>/$ver_base/'\
	-e 's/<req_version>/$E3_REQUIRE_VERSION/'\
	< $serviceNameGit" > $serviceName

systemctl enable ioc@llrf.service


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
iocshLoad $\(E3_CMD_TOP\)\/aliasing.iocsh \\\n"
  eval "sed -e $'s/<snippet>/$snippet/g' < $EPICS_SRC/e3-sis8300llrf/startup/llrf_template.cmd  > $siteApp/llrf.cmd" 
else
  if [ ${#slots_fpga} -eq 1 ]; then
     i='' # just one board, use original IOC name
  else
     i=1 # more than 1 board, enumerate IOC name
  fi

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

if [ ! -L /etc/systemd/system/multi-user.target.wants/ioc@llrf.service ] ; then
  echo "ioc@llrf.service is not enabled."
fi
systemctl daemon-reload

# Alias template
cp alias.template $siteApp/alias.template
