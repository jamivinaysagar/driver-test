#!/bin/sh

#Description: This script is for testing accelerometer of DUT.
#Input Parameter: No input required.
#Success Criteria: Accelerometer information should be provided successfully.

IIONUM=$1

IIODIR=/sys/devices/platform/lis3lv02d
POSITION=$IIODIR/position
RATE=$IIODIR/rate

if [ -z "$IIODIR" ] || ! [ -d "$IIODIR" ]; then
    echo "Error: Directory $IIODIR Not found!\n"
    echo "FAIL"
    exit 1
fi

NAME=$IIODIR/input/input*/name

if [ -z "$NAME" ]; then
    echo "Error: Couldn't capture the Accelerometer Device name!!!"
    echo "FAIL"
    exit 1
else
    echo Accelerometer Device: $(cat $NAME)
fi

if [ -z "$POSITION" ]; then
    echo "Couldn't get the Accelerometer position"
    echo "FAIL"
    exit 1
else
    echo Position: $(cat $POSITION)
fi

if [ -z "$RATE" ]; then
    echo "Couldn't get the Accelerometer rate"
    echo "FAIL"
    exit 1
else
    echo Rate: $(cat $RATE)
    echo "SUCCESS"
    exit 0
fi
