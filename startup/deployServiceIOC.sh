#!/bin/sh
if [ "$EUID" -ne 0 ] ; then
  echo "Deployment script must be run with root priviledges, exiting..." 
  exit
fi

if [[ $# -eq 3 ]] ; then
  EPICS_SRC=$1
  EPICS_BASE=$2
  E3_REQUIRE_VERSION=$3 
else
  echo "Usage: sudo deployServiceIOC.sh <e3 source directory> <epics base directory> <epics require version"
  echo "e.g. sudo sh deployServiceIOC.sh $EPICS_SRC $EPICS_BASE $E3_REQUIRE_VERSION"
  exit
fi

hostName=$(hostname)
serviceName=/etc/systemd/system/ioc@llrf.service
serviceNameGit=$EPICS_SRC/e3-sis8300llrf/startup/ioc@llrf.service
#Prepare service and enable

#Insert EPICS base version and require version into service unit ioc@llrf

#Escape the forward slash characters in EPICS_BASE path
EPICS_BASE=${EPICS_BASE//\//\\\/}
eval "sed -e 's/icslab-llrf/$hostName/'\
	-e 's/<epics_base>/$EPICS_BASE/'\
	-e 's/<req_version>/$E3_REQUIRE_VERSION/'\
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

  eval "sed 's/<slot>/$slot_fpga/' < $EPICS_SRC/e3-sis8300llrf/startup/llrf_template.cmd  > $siteApp/llrf.cmd"
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
