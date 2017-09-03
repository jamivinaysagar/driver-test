#!/bin/sh

BUS=$1
ADDR=$2
COMMAND=$3
EXPECTED_RESPONSE=$4

i2cset -y -f $BUS $ADDR $COMMAND
RESPONSE=$(i2cget -y -f $BUS $ADDR)
RESULT=$?

if [ -z "$EXPECTED_RESPONSE" ]; then
    exit $RESULT
else
    if [[ "$RESPONSE" == "$EXPECTED_RESPONSE" ]]; then
        exit 0
    else
        exit 1
    fi
fi
