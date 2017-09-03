#!/bin/sh

DEVICE_ID=$1

cat /proc/bus/pci/devices | awk '{ print $2 }' |grep -i $DEVICE_ID
