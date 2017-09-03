#!/bin/sh -e

#Description: Tests the USB device interface by performing file write followed by read/verify operation.
#Requirements: This test uses lsblk from the util-linux package.
#Input Parameter: No input required.
#Success Criteria: Read and written file on device must be same.


trap cleanup EXIT

remove_module(){
set +e	
	lsmod | grep g_mass_storage > /dev/null
	if [ $? == 0 ]; then
		rmmod g_mass_storage
	fi
set -e	
}

cleanup(){
	if [ -e "$INFILE" ]; then
		rm $INFILE
	fi
	if [ -e "$OUTFILE" ]; then
		rm $OUTFILE
	fi	
	sync
	umount $MOUNT_POINT
	remove_module
}

LSBLK_VERSION=$(which lsblk)

if [ -z "$LSBLK_VERSION" ]; then
    echo "This test depends upon util-linux for lsblk."
    echo "Make sure util-linux is installed."
    exit 1
fi

sleep 5

DEVICE="/dev/$(lsblk -S | grep 'File-Stor Gadget' | cut -f 1 -d ' ')"

if [ -z "$DEVICE" ]; then
    echo "Error: No USB gadget detected!!!"
    exit 1
fi

MOUNT_POINT=$(mount |grep -i $DEVICE | awk '{ print $3 }')

INFILE=/tmp/input.dat
OUTFILE=$MOUNT_POINT/output.dat

BS=1k
COUNT=500

echo "+++ Generating random data"
dd if=/dev/urandom of=$INFILE bs=$BS count=$COUNT

echo "+++ Writing random data to $MOUNT_POINT"
cp $INFILE $OUTFILE
sync

echo "+++ Reading data from $MOUNT_POINT"
MD5IN=$(md5sum $INFILE | awk '{print $1}')
MD5OUT=$(md5sum $OUTFILE | awk '{print $1}')

if [[ "$MD5IN" == "$MD5OUT" ]]; then
	echo "+++ Files match"
	exit 0
else
	echo "+++ Data mismatch"
	exit 1
fi
