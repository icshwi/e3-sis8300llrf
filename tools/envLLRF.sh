#!/usr/bin/bash

if [ $# -ne 1 ]; then
    echo 'usage: envLLRF.sh <$EPICS_SRC>'
    exit 1
fi

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
lspci -v | grep Xilinx
lspci -v | grep Juelich
echo "*** EPICS Bases Available***"
ls /epics/ | grep base
echo "*** EPICS Modules Installed ***"
make -C $EPICS_SRC/e3-asyn existent | grep "[0-9]\+\.[0-9]\+\.[0-9]\+"
make -C $EPICS_SRC/e3-loki existent | grep "[0-9]\+\.[0-9]\+\.[0-9]\+"
make -C $EPICS_SRC/e3-nds existent | grep "[0-9]\+\.[0-9]\+\.[0-9]\+"
make -C $EPICS_SRC/e3-sis8300drv existent | grep "[0-9]\+\.[0-9]\+\.[0-9]\+"
make -C $EPICS_SRC/e3-sis8300 existent | grep "[0-9]\+\.[0-9]\+\.[0-9]\+"
make -C $EPICS_SRC/e3-sis8300llrfdrv existent | grep "[0-9]\+\.[0-9]\+\.[0-9]\+"
make -C $EPICS_SRC/e3-sis8300llrf existent | grep "[0-9]\+\.[0-9]\+\.[0-9]\+"
make -C $EPICS_SRC/e3-mrfioc2 existent | grep "[0-9]\+\.[0-9]\+\.[0-9]\+" 
