#!/bin/sh

IIONUM=$1

IIODIR=/sys/bus/iio/devices/iio\:device${IIONUM}/

if [ -z "$IIODIR" ] || ! [ -d "$IIODIR" ]; then
    echo "Directory $IIODIR Not found!\n"
    exit 1
fi

NAME=$IIODIR/name
NUMAXES=$(ls -1 ${IIODIR}/in_accel_*_raw | wc -l)

function get_input {
    AXIS=$1

    FILENAME=$IIODIR/in_accel_${AXIS}_raw

    VALUE=$(cat $FILENAME 2> /dev/null)
    if [[ "$?" != "0" ]]; then
        echo "ERROR"
        exit 1
    else
        echo $VALUE
    fi
}

RETVAL=0

echo Accelerometer Device: $(cat $NAME)
echo Number of Axes: $NUMAXES

case $NUMAXES in
1)
    RANGE="x"
    ;;
2)
    RANGE="x y"
    ;;
3)
    RANGE="x y z"
    ;;
*)
    echo "Unsupported number of Axes: $NUMAXES"
    exit 1
    ;;
esac

for i in $RANGE; do
    VALUE=$(get_input $i)
    if [[ "$?" != "0" ]]; then RETVAL=1; fi
    echo "    Input $i: $(get_input $i)"
done

exit $RETVAL
