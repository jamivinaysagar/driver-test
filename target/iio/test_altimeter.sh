#!/bin/sh

IIONUM=$1

IIODIR=/sys/bus/iio/devices/iio\:device${IIONUM}/

if [ -z "$IIODIR" ] || ! [ -d "$IIODIR" ]; then
    echo "Directory $IIODIR Not found!\n"
    exit 1
fi

NAME=$IIODIR/name

function get_input {
    TYPE=$1

    RAWFILE=$IIODIR/in_${TYPE}_raw
    SCALEFILE=$IIODIR/in_${TYPE}_scale

    RAWVALUE=$(cat $RAWFILE 2> /dev/null)
    if [[ "$?" != "0" ]]; then
        echo "ERROR"
        exit 1
    fi

    SCALEVALUE=$(cat $SCALEFILE 2> /dev/null)
    if [[ "$?" != "0" ]]; then
        echo "ERROR"
        exit 1
    fi

    echo $RAWVALUE $SCALEVALUE
}

RETVAL=0

echo Altimeter Device: $(cat $NAME)
printf "    %-10s  %10s %10s %10s\n" "Type" "Value" "Raw Value" "Scale"
printf "    %-10s  %10s %10s %10s\n" "====" "=====" "=========" "====="
for i in temp pressure; do
    VALUE=$(get_input $i)
    if [[ "$?" != "0" ]]; then
        RETVAL=1;
        RAW="ERROR"
        SCALE="ERROR"
        SCALEDVALUE="ERROR"
    else
        RAW=$(echo $VALUE | awk '{print $1}')
        SCALE=$(echo $VALUE | awk '{print $2}')
        SCALEDVALUE=$(awk "BEGIN {print $RAW * $SCALE}")
    fi

    printf "    %-10s: %10f %10d %10f\n" $i $SCALEDVALUE $RAW $SCALE
done

exit $RETVAL
