#!/bin/sh

GPIODIR=/sys/class/gpio

RATE=1
COUNT=10

debug()
{
	if [ ! -z $VERBOSE ]; then
		echo "$@"
	fi
}

usage()
{
	echo "Usage: $0 [OPTIONS] [GPIO]" >&2
	echo ""
	echo "Options: -r [RATE]  Blink rate (in seconds) (Default 1)"
	echo "         -c [COUNT] Number of repetitions (Default 10)"
	echo "         -h         This help text"
	echo "         -v         Verbose output.  Shows commands being run."
	echo "         GPIO       GPIO number to test"
	echo
	echo "Example: $0 `echo $LEDS | awk '{print $1}'`"
}

toggle_gpio()
{
	GPIONUM=$1
	VALUE=$2

	GPIOFILE=$GPIODIR/gpio$GPIONUM

	debug "echo $VALUE > $GPIOFILE/value"
	echo $VALUE > $GPIOFILE/value
}

while getopts ":vr:c:" opt; do
	case $opt in
	r)
		RATE=$OPTARG
		;;
	c)
		COUNT=$OPTARG
		;;
	v)
		VERBOSE=1
		;;
	\?)
		usage
		exit 1
		;;
	esac
done

shift `expr $OPTIND - 1`
if [ -z $@ ]; then
	usage
	exit 1
fi

GPIONUM=$1

if [ ! -e $GPIODIR/gpio$GPIONUM ]; then

	debug "$GPIONUM > $GPIODIR/export"
	echo $GPIONUM > $GPIODIR/export

	if [ ! $? -eq 0 ]; then
		echo "FATAL: Invalid GPIO number"
		exit 1
	fi
fi

debug "echo out > $GPIODIR/gpio$GPIONUM/direction"
echo out > $GPIODIR/gpio$GPIONUM/direction
VALUE=1

for i in $(seq 1 $COUNT); do

	if [ $VALUE -eq 1 ]; then
		VALUE=0
	else
		VALUE=1
	fi
	toggle_gpio $GPIONUM $VALUE

	debug "sleep $RATE"
	sleep $RATE
done

exit 0
