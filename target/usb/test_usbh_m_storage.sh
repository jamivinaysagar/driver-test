#!/bin/sh -e

#Assumption: Script is used from an interactive test
#User plugs in USB drive and we assume the last mounted device
#is the USB drive and test it

#Alternatives: Make this script less hacky in the future:
# Option1: Integrate with udev to detect USB hotplugs (not all customers might use udev)
# Option2: Use /dev/disk/by- instead of replying on mount


RUNTIME=$1

sleep 3
DEVICE=$(mount |tail -1 | awk '{ print $1 }')
DEV_ID=$(echo $DEVICE | cut -c 6-)

if [ -z $DEV_ID ]; then
	exit 1
fi

#Check if device is a USB device
ls -al /sys/class/block/$DEV_ID | grep usb

MOUNT_POINT=$(mount |tail -1 | awk '{ print $3 }')

if [ -z $RUNTIME ]; then
	bin/fs/test_fs.sh -t mount -f $MOUNT_POINT
else
	bin/fs/test_fs.sh -t mount -f $MOUNT_POINT -r $RUNTIME
fi
