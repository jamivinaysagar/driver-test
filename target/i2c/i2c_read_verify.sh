#!/bin/sh

BUS=$1
I2C_ADDR=$2
REG_ADDR=$3
EXPECTED_RESPONSE=$4

RESPONSE=$(i2cget -y -f $BUS $I2C_ADDR $REG_ADDR)
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
