#!/bin/sh

LEDDIR=/sys/class/leds

LEDS=`ls $LEDDIR`
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
	echo "Usage: $0 [OPTIONS] [LED]" >&2
	echo ""
	echo "Options: -l         List LEDs on the system"
	echo "         -r [RATE]  Blink rate (in seconds) (Default 1)"
	echo "         -c [COUNT] Number of repetitions (Default 10)"
	echo "         -a         Blink all the LEDS"
	echo "         -v         Verbose output.  Shows commands being run."
	echo "         -h         This help text"
	echo
	echo "Example: $0 `echo $LEDS | awk '{print $1}'`"
}

toggle_led()
{
	LEDNAME=$1

	LEDFILE=$LEDDIR/$LEDNAME

	MAX_BRIGHTNESS=`cat $LEDFILE/max_brightness`
	if [[ `cat $LEDFILE/brightness` -eq $MAX_BRIGHTNESS ]]; then
		debug "echo 0 > $LEDFILE/brightness"
		echo 0 > $LEDFILE/brightness
	else
		debug "echo $MAX_BRIGHTNESS > $LEDFILE/brightness"
		echo $MAX_BRIGHTNESS > $LEDFILE/brightness
	fi
}

while getopts ":lvar:c:" opt; do
	case $opt in
	l)
		echo "LEDs available: `echo $LEDS | wc -w`"
		for LED in $LEDS; do
			echo "  $LED"
		done
		exit 0
		;;
	r)
		RATE=$OPTARG
		;;
	a)
		ALLTEST=1
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

# If -a is specified, or the list is empty, toggle everything
shift `expr $OPTIND - 1`
if [ -z $ALLTEST ] && [ ! -z $@ ]; then
	LEDS=$@
fi

for i in $(seq 1 $COUNT); do
	for LED in $LEDS; do
		toggle_led $LED
	done
	debug "sleep $RATE"
	sleep $RATE
done

exit 0
