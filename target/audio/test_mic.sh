#!/bin/sh

CHANNELS=2
FORMAT=dat
TIME=5
DEVICE=$1
FILE=$2

amixer sset "PCM" "144"
amixer sset "Mic" "1"
amixer sset "Headphone" "41"
amixer sset "Capture" "15"
amixer sset "Capture Mux" "MIC_IN"

echo "Playing 500Hz tone and recording for 5 seconds..."
aplay -D $DEVICE -q $FILE &
arecord -q -d $TIME -f $FORMAT -c $CHANNELS /tmp/test-mic.wav
sleep 2
aplay -D $DEVICE -q /tmp/test-mic.wav
rm /tmp/test-mic.wav

exit 0
