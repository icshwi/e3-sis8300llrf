#!/usr/bin/bash

echo "*** Kernel Release ***"
uname -a
echo "*** UDev rules***"
ls /etc/udev/rules.d/99-*
echo "*** Kernel Module Load Rules ***"
ls /etc/modules-load.d/mrf.conf
ls /etc/modules-load.d/sis8300drv.conf
echo "*** Kernel Modules Loaded***"
lsmod | grep sis8300drv
lsmod | grep mrf
echo "*** Device Nodes***"
ls /dev/sis8300-*
ls /dev/uio*
echo "*** OS Release***"
cat /etc/centos-release
echo "*** systemd configuration ***"
echo " *service "
file /etc/systemd/system/ioc@llrf.service
echo " *service wants configuration "
file /etc/systemd/system/multi-user.target.wants/ioc@llrf.service
echo "*** Hardware Device ***"
lspci -tv
echo "*** EPICS Bases Available***"
ls /epics/
echo "*** EPICS Modules Installed ***"
echo "*** asyn ***"
make -C ../e3-asyn existent | grep "[0-9\+]\.[0-9\+]\.[0-9\+].*"
echo "*** loki ***"
make -C ../e3-loki existent | grep "[0-9\+]\.[0-9\+]\.[0-9\+]"
echo "*** nds ***"
make -C ../e3-nds existent | grep "[0-9\+]\.[0-9\+]\.[0-9\+]"
echo "*** sis8300drv ***"
make -C ../e3-sis8300drv existent | grep "[0-9\+]\.[0-9\+]\.[0-9\+]"
echo "*** sis8300 ***"
make -C ../e3-sis8300 existent | grep "[0-9\+]\.[0-9\+]\.[0-9\+]"
echo "*** sis8300llrfdrv ***"
make -C ../e3-sis8300llrfdrv  existent | grep "[0-9\+]\.[0-9\+]\.[0-9\+]"
echo "*** sis8300llrf ***"
make existent | grep "[0-9\+]\.[0-9\+]\.[0-9\+]"
echo "*** mrfioc2 ***"
make -C ../e3-mrfioc2 existent | grep "[0-9\+]\.[0-9\+]\.[0-9\+]" 
