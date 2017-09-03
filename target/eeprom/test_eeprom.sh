#!/bin/sh

echo "WARNING: This test MAY CORRUPT Board EEPROM"
read -p "Do you wish to CONTINUE test execution y/n? " yn
case $yn in
    [Yy]* ) continue;;
    [Nn]* ) exit;;
    * ) echo "INVALID INPUT: Please answer y/n"; exit;;
esac

DEVICE=$1
PAGESIZE=$2

INFILE=/tmp/input.dat
OUTFILE=/tmp/output.dat
EEPROM_BACKUP=/tmp/eeprom_dump

if [ -e "$DEVICE" ]; then
    SIZE=$(ls -l $DEVICE | awk -v N=$4 '{print $5}')
else
    echo "+++ File ${DEVICE} not found"
    echo
    echo "+++ Usage: $0 [device name]"
    exit 1
fi

if [ -n "$PAGESIZE" ]; then
    BS=$PAGESIZE
    COUNT=$(($SIZE/$BS))
else
    BS=1
    COUNT=$SIZE
fi

echo "+++ Device=${DEVICE} Size=${SIZE} Pagesize=${BS} Count=${COUNT}"

echo "+++ Taking backup of eeprom"
dd if=$DEVICE of=$EEPROM_BACKUP

echo "+++ Generating random data"
dd if=/dev/urandom of=$INFILE bs=$BS count=$COUNT

echo "+++ Writing random data to $DEVICE"
dd if=$INFILE of=$DEVICE bs=$BS count=$COUNT

echo "+++ Reading data from $DEVICE"
dd if=$DEVICE of=$OUTFILE bs=$BS count=$COUNT

MD5IN=$(md5sum $INFILE | awk '{print $1}')
MD5OUT=$(md5sum $OUTFILE | awk '{print $1}')

echo "+++ Writing backup file into $DEVICE"
dd if=$EEPROM_BACKUP of=$DEVICE

rm $INFILE $OUTFILE $EEPROM_BACKUP

if [[ "$MD5IN" == "$MD5OUT" ]]; then
    echo "+++ Files match"
    exit 0
else
    echo "+++ Data mismatch"
    exit 1
fi
