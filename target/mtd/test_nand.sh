#!/bin/sh

echo "WARNING: This test MAY CORRUPT Board NAND Flash"
read -p "Do you wish to CONTINUE test execution y/n? " yn
case $yn in
    [Yy]* ) continue;;
    [Nn]* ) exit;;
    * ) echo "INVALID INPUT: Please answer y/n"; exit;;
esac

PART=$1
ALLOWED_BADBLOCKS=0
if [[ -n $2 ]]; then
   ALLOWED_BADBLOCKS=$2
fi

SYSFSDIR=/sys/class/mtd/mtd$PART/
DEVICE=/dev/mtd$PART
BLKDEVICE=/dev/mtdblock$PART

PARTSIZE=$(cat $SYSFSDIR/size)
ERASESIZE=$(cat $SYSFSDIR/erasesize)
ERASEBLOCKS=$(($PARTSIZE/$ERASESIZE))
WRITE_BLOCKS=$(($ERASEBLOCKS-$ALLOWED_BADBLOCKS))
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

function random_test
{
    printf "Random Test\n"
    printf "==========\n"

    INFILE=/tmp/input.dat
    OUTFILE=/tmp/output.dat

    # Generate random file
    dd if=/dev/urandom bs=$ERASESIZE count=$WRITE_BLOCKS | tr "\000" "\377" > $INFILE

    echo "+++ Erasing flash"
    flash_erase $DEVICE 0 0

    echo "+++ Writing file to flash"
    nandwrite $DEVICE $INFILE
    
    echo "+++ Reading flash"    
    READ_SIZE=$(($ERASESIZE*$WRITE_BLOCKS))
    nanddump $DEVICE -l $READ_SIZE -f $OUTFILE

    if [[ $(compare $INFILE $OUTFILE) == "0" ]]; then
        echo "+++ Write Successful"
    else
        echo "+++ Write Failure"
        RETVAL=1
    fi

    rm $INFILE $OUTFILE
}

printf "MTD $PART\n"
printf "  NAND Flash\n"
printf "  Total Size: 0x%x (%d)\n" $PARTSIZE $PARTSIZE
printf "  Erase Size: 0x%x (%d)\n" $ERASESIZE $ERASESIZE
printf "  Number Blocks: %d\n" $ERASEBLOCKS
printf "\n"

random_test

exit $RETVAL
