
e3-sis8300llrf  
======
ESS Site-specific EPICS module : sis8300llrf

## Startup scripts

* To deploy this IOC as service use the script startup/deployServiceIOC.sh :
`sudo ./deployServiceIOC.sh <e3 source directory> <epics base directory> <epics require version> `

The IOC will then run on boot of the system. Alternatively for manual initiation the startup script for the system can be found at /epics/iocs/sis8300llrf/llrf.cmd

## Timing support
This EPICS module provides basic timing support by the instantiation of the timing_template.iocsh code snippet. This snippet is instantiated with the correct PCIe enumeration of the EVR available on the bus if one is present. Soft sequencer functionality is provided via the tr-sequencer.sh script where and event generator is not present. This script should be run after IOC initialisation to start the soft sequence of timing events internally in the EVR.
