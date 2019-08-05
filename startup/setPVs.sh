#!/bin/bash
caput -s ${LLRF_IOC_NAME}:AI0-MAG.DESC "PreAmp Fwd"
caput -s ${LLRF_IOC_NAME}:AI1-MAG.DESC "PwrAmp Fwd"
caput -s ${LLRF_IOC_NAME}:AI2-SMON-MAGCURR.DESC "PwrAmp Rflct"
caput -s ${LLRF_IOC_NAME}:AI3-SMON-MAGCURR.DESC "Circ Fwd"
caput -s ${LLRF_IOC_NAME}:AI4-SMON-MAGCURR.DESC "Cav1 Fwd"
caput -s ${LLRF_IOC_NAME}:AI5-SMON-MAGCURR.DESC "Cav1 Reflct"
caput -s ${LLRF_IOC_NAME}:AI6-SMON-MAGCURR.DESC "Cav2 Fwd"
caput -s ${LLRF_IOC_NAME}:AI7-SMON-MAGCURR.DESC "Cav2 Reflct"

