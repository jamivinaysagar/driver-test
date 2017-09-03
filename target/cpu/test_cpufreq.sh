#!/bin/sh

CPU=$1

if [ -z "$CPU" ]; then
    CPU=0
fi

CPUFREQDIR=/sys/bus/cpu/devices/cpu$CPU/cpufreq/

if ! [ -d "$CPUFREQDIR" ]; then
    echo "CPU Frequency Scaling is not available for this processor!"
    exit 1
fi

MINFREQ=$(cat ${CPUFREQDIR}/cpuinfo_min_freq)
MAXFREQ=$(cat ${CPUFREQDIR}/cpuinfo_max_freq)
GOVERNERS=$(cat ${CPUFREQDIR}/scaling_available_governors)
FREQUENCIES=$(cat ${CPUFREQDIR}/scaling_available_frequencies)

CURGOVFILE=${CPUFREQDIR}/scaling_governor
CURFREQFILE=${CPUFREQDIR}/scaling_cur_freq
SETFREQFILE=${CPUFREQDIR}/scaling_setspeed

TESTFILE=/tmp/testfile.dat
TESTFILESIZE=16

dd if=/dev/urandom of=$TESTFILE bs=1M count=$TESTFILESIZE > /dev/null 2>&1

echo "Testing CPU Frequency on CPU$CPU"
echo "  Available Governers: $GOVERNERS"
echo "  Available Frequencies: $FREQUENCIES"
echo ""

# Test manual frequency setting (if supported)
if [[ "$(cat $SETFREQFILE)" != "<unsupported>" ]]; then
    echo "Manual Set Speed Tests"
    echo "======================"
    for freq in $FREQUENCIES; do
        echo $freq > $SETFREQFILE
        if [[ "$(cat $CURFREQFILE)" != "$freq" ]]; then
            echo "Set frequency to $freq failed"
            continue
        fi
        echo "Running at $freq Hz"
        time md5sum $TESTFILE
    done
else
    echo "Skipping Manual Set Speed Tests (unsupported feature)"
fi

echo ""
echo "Governer Tests"
echo "=============="

for gov in $GOVERNERS; do
    echo $gov > $CURGOVFILE
    if [[ "$(cat $CURGOVFILE)" != "$gov" ]]; then
        echo "Set Governer to $gov failed"
        continue
    fi
    echo "Governer: $gov"
    sleep 2 # Give system some time to adjust to new governer
    echo "    Unloaded speed: $(cat $CURFREQFILE)"
    (time md5sum $TESTFILE > /dev/null) &> /tmp/testspeed.txt
    echo "    Loaded speed: $(cat $CURFREQFILE)"
    cat /tmp/testspeed.txt
    rm /tmp/testspeed.txt
    echo ""
done 

rm $TESTFILE
