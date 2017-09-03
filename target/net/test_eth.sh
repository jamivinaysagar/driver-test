#!/bin/sh

INTERFACE=$1
PINGLOC=$2

if [ -z "$INTERFACE" ]; then
    INTERFACE=eth0
fi

if [ -z "$PINGLOC" ]; then
    SKIPPINGTEST=1
    echo "Skipping ping test"
fi

if ! ifconfig $INTERFACE up; then
    echo "Device $INTERFACE not found!"
    exit 1
fi

if ! udhcpc -i $INTERFACE -t 5 -n; then
    echo "Could not get IP Address"
    ifconfig $INTERFACE down
    exit 1
fi

if [ -z "$SKIPPINGTEST" ] && ! ping $PINGLOC -c 5; then
    echo "Could not connect to internet"
    ifconfig $INTERFACE down
    exit 1
fi

ifconfig $INTERFACE down

exit 0
