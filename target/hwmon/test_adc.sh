#!/bin/sh

HWMONNUM=$1

HWMONDIR=/sys/class/hwmon/hwmon$HWMONNUM/

if [ -z "$HWMONDIR" ] || ! [ -d "$HWMONDIR" ]; then
    echo "Directory $HWMONDIR Not found!\n"
    exit 1
fi

NAME=$HWMONDIR/name
NUMINPUTS=$(ls -1 ${HWMONDIR}/in* | wc -l)

function get_input {
    INPUTNUM=$1

    FILENAME=$HWMONDIR/in${INPUTNUM}_input

    VALUE=$(cat $FILENAME 2> /dev/null)
    if [[ "$?" != "0" ]]; then
        echo "ERROR"
        exit 1
    else
        echo $VALUE
    fi
}


RANGE=$(seq 0 $(($NUMINPUTS - 1)))

RETVAL=0

echo ADC: $(cat $NAME)
echo Number of Inputs: $NUMINPUTS

for i in $RANGE; do
    VALUE=$(get_input $i)
    if [[ "$?" != "0" ]]; then RETVAL=1; fi
    echo "    Input $i: $(get_input $i)"
done

exit $RETVAL
