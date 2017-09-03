#!/bin/sh

BLDIR=/sys/class/backlight

BLS=`ls $BLDIR`
DELAY=0

debug()
{
	if [ ! -z $VERBOSE ]; then
		echo "$@"
	fi
}

usage()
{
	echo "Usage: $0 [OPTIONS] [BACKLIGHT]" >&2
	echo ""
	echo "Increase backlight from zero to maximum brightness"
	echo ""
	echo "Options: -l         List backlights on the system"
	echo "         -a         Test all the backlights"
	echo "         -d sec     Delay sec seconds between brightness updates (default 0)"
	echo "         -v         Verbose output.  Shows commands being run."
	echo "         -h         This help text"
	echo
	echo "Example: $0 `echo $BLS | awk '{print $1}'`"
}

test_bl()
{
	BLNAME=$1
	
	BLFILE=$BLDIR/$BLNAME

	MAX_BRIGHTNESS=`cat $BLFILE/max_brightness`

	# Power up backlight
	debug "echo 0 > $BLFILE/bl_power"
	echo 0 > $BLFILE/bl_power

	# Bring it from zero to max brightness
	for i in $(seq 0 $MAX_BRIGHTNESS); do
		debug "echo $i > $BLFILE/brightness"
		sleep $DELAY
		echo $i > $BLFILE/brightness
	done
}

while getopts ":lvaid:" opt; do
	case $opt in
	l)
		echo "Backlights available: `echo $BLS | wc -w`"
		for BL in $BLS; do
			echo "  $BL"
		done
		exit 0
		;;
	d)
		DELAY=$OPTARG
		;;
	a)
		ALLTEST=1
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
	BLS=$@
fi

for BL in $BLS; do
	test_bl $BL
done

exit 0
