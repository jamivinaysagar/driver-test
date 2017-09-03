#!/bin/sh

DEVICE=$1
AUDIO_FILE=$2

amixer sset PCM 192
amixer sset Headphone 127

aplay -D $DEVICE $AUDIO_FILE

exit 0
