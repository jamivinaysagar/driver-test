#!/bin/sh -e

FILE_PATH=$1

trap cleanup EXIT

cleanup(){
	if [ -e "$INFILE" ]; then
		rm $INFILE
	fi
	if [ -e "$OUTFILE" ]; then
		rm $OUTFILE
	fi

	umount $MOUNT_POINT
}

write_verify_test(){
	BS=1k
	COUNT=$(shuf -i 1-10000 -n 1)

	if [ ! -z "$MAX_SIZE" ]; then
		if [ "$COUNT" -gt "$MAX_SIZE" ]; then
			COUNT=$MAX_SIZE
		fi
	fi

	echo "+++ Generating random data"
	dd if=/dev/urandom of=$INFILE bs=$BS count=$COUNT

	echo "+++ Writing random data to $MOUNT_POINT"
	cp $INFILE $OUTFILE
	sync
	echo 3 > /proc/sys/vm/drop_caches 

	echo "+++ Reading data from $MOUNT_POINT"
	MD5IN=$(md5sum $INFILE | awk '{print $1}')
	MD5OUT=$(md5sum $OUTFILE | awk '{print $1}')

	if [[ "$MD5IN" == "$MD5OUT" ]]; then
		echo "+++ Files match"
	else
		echo "+++ Data mismatch"

		exit 1
	fi
}

usage()
{
	echo "Usage: $0 DEVICE" >&2
	echo ""
	echo "DEVICE: the path to the device being tested."
	echo "Examples: $0 /dev/sda1"
}

if [ $# -eq 0 ]; then
	usage
	exit 1
fi

MOUNT_POINT=$(mount |grep $FILE_PATH | awk '{ print $3 }')
if [ -z "$MOUNT_POINT" ]; then
    TEMP_DIR=$(date "+%Y%m%d%H%M%S")
    MOUNT_POINT="/tmp/$TEMP_DIR"
    mkdir $MOUNT_POINT
    mount $FILE_PATH $MOUNT_POINT
    sleep 2
fi

if [ ! -d $MOUNT_POINT ] || [ -z $MOUNT_POINT ]; then
	echo "$MOUNT_POINT is not a valid directory"
	exit 1
fi

INFILE=/tmp/input.dat
OUTFILE=$MOUNT_POINT/output.dat
MAX_SIZE=$(df | grep $MOUNT_POINT | awk '{ print $4 }')

write_verify_test

exit 0
