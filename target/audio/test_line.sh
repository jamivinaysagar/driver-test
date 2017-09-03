#!/bin/sh

CHANNELS=2
FORMAT=dat
TIME=5
DEVICE=$1

amixer sset "PCM" "144"
amixer sset "Headphone" "41"
amixer -q sset "Capture" "15"
amixer -q sset "Capture Mux" "LINE_IN"

echo "Recording from Line IN for 5 seconds..."
arecord -q -d $TIME -f $FORMAT -c $CHANNELS /tmp/test-line.wav

aplay -D $DEVICE -q /tmp/test-line.wav
rm /tmp/test-line.wav

exit 0
