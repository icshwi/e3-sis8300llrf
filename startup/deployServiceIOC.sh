#!/bin/sh
if [ "$EUID" -ne 0 ] ; then
  echo "Deployment script must be run with root priviledges, exiting..." 
  exit
fi

if [[ $# -gt 0 ]] ; then
  EPICS_SRC=$1
else
  echo "Usage: sudo deployServiceIOC.sh <e3 source directory> <epics base directory> <epics require version> <LLRF_IOC_NAME>"
  echo "sudo deployServiceIOC.sh $EPICS_SRC $EPICS_BASE $E3_REQUIRE_VERSION"
  exit
fi

hostName=$(hostname)
serviceName=/etc/systemd/system/ioc@llrf.service
serviceNameGit=$EPICS_SRC/e3-sis8300llrf/startup/ioc@llrf.service
#Prepare service and enable

#Get EPICS base version and require version
ver_base=$(echo $2 | cut -c13-18)
eval "sed -e 's/icslab-llrf/$hostName/'\
	-e 's/<epics_base>/$ver_base/'\
	-e 's/<req_version>/$3/'\
	< $serviceNameGit" > $serviceName

systemctl enable ioc@llrf.service


#Prepare siteApp configuration for IOC instance specific configuration
siteApp=/epics/iocs/sis8300llrf
mkdir -p $siteApp/log/
mkdir -p $siteApp/run/

slot_fpga=$(ls /dev | grep sis8300 | cut -c9-10)
if [ ${#slot_fpga} -lt 1 ] ; then 
  echo "Could not find SIS8300 digitiser board."
  echo "Board slot must be manually configured in $siteApp/llrf.cmd"
  cp $EPICS_SRC/e3-sis8300llrf/startup/llrf_template.cmd $siteApp/llrf.cmd
else
  #Populate digitiser slot and IOC Name in startup script.
  eval "sed -e 's/<slot>/$slot_fpga/'\
    -e 's/<LLRF_IOC_NAME>/$4/'\
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
  eval "sed 's/<B:D.F>/$pcie_enumeration/' < $EPICS_SRC/e3-sis8300llrf/startup/timing_template.iocsh" > "/epics/iocs/sis8300llrf/timing.iocsh"
  cp $EPICS_SRC/e3-sis8300llrf/startup/tr-sequencer.sh $siteApp/tr-sequencer.sh
fi

if [ ! -L /etc/systemd/system/multi-user.target.wants/ioc@llrf.service ] ; then
  echo "ioc@llrf.service is not enabled."
fi
systemctl daemon-reload
