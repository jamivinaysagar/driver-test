#!/bin/sh

FILE=$1
RUNTIMEDIR=$2

if [ -z "$RUNTIMEDIR" ]; then
    XDG_RUNTIME_DIR=/var/run/user/1000/
fi

weston-image $FILE &
PID=$!
sleep 5
kill $PID
