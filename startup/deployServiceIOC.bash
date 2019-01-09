#!/usr/bin/bash
if [ "$EUID" -ne 0 ] ; then
  echo "Deployment script must be run with root priviledges, exiting..." 
  exit
fi

if [ $# -eq 0 ] ; then
  echo "usage: <e3 source directory>"
  exit
fi

EPICS_SRC=$1
hostName=$(hostname)
echo "Preparing systemd service to run IOC on host $hostName"
serviceName=/etc/systemd/system/ioc@llrf.service
serviceNameGit=$EPICS_SRC/e3-sis8300llrf/startup/ioc@llrf.service
#Prepare service and enable
sed 's/icslab-llrf/$hostName/' < $serviceNameGit > $serviceName
systemctl enable ioc@llrf.service

#Prepare siteApp configuration for IOC instance specific configuration
siteApp=/epics/base-3.15.5/require/3.0.4/siteApps/sis8300llrf
mkdir -p $siteApp/log/procServ/
mkdir -p $siteApp/run/procServ/
cp $EPICS_SRC/e3-sis8300llrf/startup/llrf.cmd $siteApps/llrf.cmd

echo "*Check - service created:"
file $serviceName
echo "*Check - service enabled:"
wantsFile=${serviceName/ioc@llrf/multi-user.target.wants\\ioc@llrf}
file $wantsFile
echo "Check SiteApps directory for IOC configuration"
tree $siteApp
