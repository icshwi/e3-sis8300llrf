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
if [ ! -d $siteApp/log ]; then
  mkdir -p "$siteApp/log/"
fi
if [ ! -d $siteApp/run ]; then
  mkdir -p "$siteApp/run/"
fi

chown -R iocuser $siteApp

if [ ! -L /etc/systemd/system/multi-user.target.wants/ioc@llrf.service ] ; then
  echo "ioc@llrf.service is not enabled."
fi
systemctl daemon-reload

