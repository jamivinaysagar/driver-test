#!/bin/sh

FILE=$1
OUTPUT=$2
DISPLAY=$3

if [ -z "$DISPLAY" ]; then
    DISPLAY=:0
fi

if [ -n "$OUTPUT" ]; then
    DISPLAY=$DISPLAY xrandr --auto --output $OUTPUT
    sleep 2
fi

DISPLAY=$DISPLAY display.im6 -delay 5 -loop 1 $FILE
