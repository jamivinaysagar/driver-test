#!/bin/sh

echo "WARNING: This test MAY CORRUPT Board NOR Flash"
read -p "Do you wish to CONTINUE test execution y/n? " yn
case $yn in
    [Yy]* ) continue;;
    [Nn]* ) exit;;
    * ) echo "INVALID INPUT: Please answer y/n"; exit;;
esac

PART=$1

SYSFSDIR=/sys/class/mtd/mtd$PART/
DEVICE=/dev/mtd$PART
BLKDEVICE=/dev/mtdblock$PART

PARTSIZE=$(cat $SYSFSDIR/size)
ERASESIZE=$(cat $SYSFSDIR/erasesize)
ERASEBLOCKS=$(($PARTSIZE/$ERASESIZE))
RETVAL=0

function compare
{
    INFILE=$1
    OUTFILE=$2

    MD5IN=$(md5sum $INFILE | awk '{print $1}') 
    MD5OUT=$(md5sum $OUTFILE | awk '{print $1}')

    if [[ "$MD5IN" == "$MD5OUT" ]]; then
        echo 0
    else
        echo 1
    fi

}

function erase_test
{
    printf "Erase Test\n"
    printf "==========\n"

    BLANK=/tmp/blank.dat
    OUTFILE=/tmp/output.dat

    # Generate blank file
    dd if=/dev/zero bs=$ERASESIZE count=$ERASEBLOCKS | tr "\000" "\377" > $BLANK

    # Erase entire flash
    echo "+++ Erasing flash"
    flash_erase $DEVICE 0 0

    # Dump flash
    echo "+++ Reading flash"
    dd if=$DEVICE of=$OUTFILE

    if [[ $(compare $BLANK $OUTFILE) == "0" ]]; then
        echo "+++ Erase Successful"
    else
        echo "+++ Erase Failure"
        RETVAL=1
    fi

    rm $BLANK $OUTFILE
}

function random_test
{
    printf "Erase Test\n"
    printf "==========\n"

    INFILE=/tmp/input.dat
    OUTFILE=/tmp/output.dat

    # Generate random file
    dd if=/dev/urandom bs=$ERASESIZE count=$ERASEBLOCKS | tr "\000" "\377" > $INFILE

    echo "+++ Erasing flash"
    flash_erase $DEVICE 0 0

    echo "+++ Writing file to flash"
    flashcp $INFILE $DEVICE
    
    echo "+++ Reading flash"
    dd if=$DEVICE of=$OUTFILE

    if [[ $(compare $INFILE $OUTFILE) == "0" ]]; then
        echo "+++ Write Successful"
    else
        echo "+++ Write Failure"
        RETVAL=1
    fi

    rm $INFILE $OUTFILE
}

printf "MTD $PART\n"
printf "  NOR Flash\n"
printf "  Total Size: 0x%x (%d)\n" $PARTSIZE $PARTSIZE
printf "  Erase Size: 0x%x (%d)\n" $ERASESIZE $ERASESIZE
printf "  Number Blocks: %d\n" $ERASEBLOCKS
printf "\n"

erase_test
random_test

exit $RETVAL
