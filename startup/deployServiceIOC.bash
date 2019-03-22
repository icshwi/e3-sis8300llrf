#!/usr/bin/bash
if [ "$EUID" -ne 0 ] ; then
  echo "Deployment script must be run with root priviledges, exiting..." 
  exit
fi

if [[ $# -gt 0 ]] ; then
  EPICS_SRC=$1
  echo "EPICS source directory specified as $EPICS_SRC"
else
  echo "Usage: deployServiceIOC.bash <e3 source directory>"
  exit
fi

hostName=$(hostname)
echo "Preparing systemd service to run IOC on host $hostName"
serviceName=/etc/systemd/system/ioc@llrf.service
serviceNameGit=$EPICS_SRC/e3-sis8300llrf/startup/ioc@llrf.service
#Prepare service and enable
eval "sed 's/icslab-llrf/$hostName/' < $serviceNameGit" > $serviceName
systemctl enable ioc@llrf.service

#Prepare siteApp configuration for IOC instance specific configuration
siteApp=/epics/iocs/sis8300llrf
mkdir -p $siteApp/log/
mkdir -p $siteApp/run/
cp $EPICS_SRC/e3-sis8300llrf/startup/llrf.cmd $siteApp/llrf.cmd

echo "*Check - service created for $hostName:"
file $serviceName
grep Host $serviceName
echo "*Check - service enabled:"
wantsDir=${serviceName/ioc@llrf.service/multi-user.target.wants}
ls $wantsDir | grep llrf
echo "Check IOC configuration"
tree $siteApp

echo "Reloading the systemd daemon configuration."
systemctl daemon-reload
