#!/bin/sh -e

cleanup(){
        if [ ! -z $CUR_DIR ]; then
                cd $CUR_DIR
        fi
        rm /tmp/input*.dat > /dev/null 2>&1 || true
        unmount_fs        
}

usage(){
        echo "Usage: $0 [OPTIONS]" >&2
        echo ""
        echo "Options: -m [mtd number]  mtd partition on which the test needs to be run"
        echo "         -p [passes]      number of times to run (default 1)"
        echo "         -j               select jffs2 instead of ubifs (defaults to ubifs)"
        echo "         -b               select between bonnie++ or generic create/verify test (defaults to generic)"
        echo "Examples: $0 -m 4"
        echo "          $0 -m 4 -p 100 -j -b"
}

check_ubi_attached(){
        UBI_VOL=$(ubinfo | grep Count | awk '{ print $5 }')
        UBI_ATTACHED=0                      
        while [ $UBI_VOL != 0 ]; do                                              
                UBI_VOL=$((UBI_VOL-1))
                UBI_DEV=$(ubinfo | grep Present |awk '{ gsub(",",""); print $TEST}' TEST=$(($UBI_VOL+4)))                                     
                MTD_NUM=$(cat /sys/devices/virtual/ubi/$UBI_DEV/mtd_num)
                if [ $MTD_NUM == $MTD_DEV ]; then                                
                        UBI_ATTACHED=1
                        break                       
                fi                                                               
        done
}

setup(){
        unmount_fs
        flash_erase /dev/mtd$MTD_DEV 0 0
        if [ ! -d $MOUNT_POINT ]; then
                mkdir -p $MOUNT_POINT
        fi
        if [ $FS_JFFS2 != 1 ]; then
                ubiformat /dev/mtd$MTD_DEV
                ubiattach /dev/ubi_ctrl -m $MTD_DEV
                sleep 1
                check_ubi_attached
                ubimkvol /dev/$UBI_DEV -Ntest -m
                ubidetach /dev/ubi_ctrl -m $MTD_DEV
        fi
}

verify(){
        COUNT=1
        while [ $COUNT != $FILE_COUNT ]; do
                MD5IN=$(md5sum /tmp/input$COUNT.dat | awk '{print $1}')
                MD5OUT=$(md5sum $MOUNT_POINT/output$COUNT.dat | awk '{print $1}')

                if [[ "$MD5IN" != "$MD5OUT" ]]; then
                        echo "+++ Data mismatch"
                        exit 1
                fi
                COUNT=$((COUNT+1))
        done
}

create_files(){
        #TODO: Change the count/bs to random sizes and limit total filesize to be less than
        # the total free space available in the file system
        COUNT=1
        while [ $COUNT != $FILE_COUNT ]; do
                dd if=/dev/urandom of=/tmp/input$COUNT.dat bs=1k count=1 > /dev/null 2>&1
                cp /tmp/input$COUNT.dat $MOUNT_POINT/output$COUNT.dat
                COUNT=$((COUNT+1))
        done
        sync
}

mount_fs(){
        if [ $FS_JFFS2 == 1 ]; then
                mount -t jffs2 /dev/mtdblock$MTD_DEV $MOUNT_POINT
                sleep 6
        else
                ubiattach /dev/ubi_ctrl -m $MTD_DEV
                sleep 1
                check_ubi_attached
                mount -t ubifs $UBI_DEV:test $MOUNT_POINT
                sleep 1
        fi
}

unmount_fs(){
        if mount | grep $MOUNT_POINT > /dev/null; then
                umount $MOUNT_POINT
        fi

        sleep 1

        check_ubi_attached
        if [ $UBI_ATTACHED == 1 ]; then
                ubidetach /dev/ubi_ctrl -m $MTD_DEV
                sleep 1
        fi
}

test_generic(){
        create_files
        verify
        unmount_fs
        mount_fs
        verify
}

#Configurations
FILE_COUNT=50
TOTAL_FILE_SIZE_IN_MB=9

#Defaults
FS_JFFS2=0
PASS_COUNT=1
TEST_BONNIE=0

while getopts ":m:p:jb" opt; do
        case "$opt" in
        m)
                MTD_DEV=$OPTARG
                ;;
        p)
                PASS_COUNT=$OPTARG
                ;;
        j)
                FS_JFFS2=1
                ;;
        b)
                TEST_BONNIE=1
                ;;
        \?)
                usage
                echo $opt
                exit 1
                ;;
        esac
done

if [ -z $MTD_DEV ]; then
        usage
        exit 1
fi

MOUNT_POINT="/mnt/mtd$MTD_DEV"

setup
mount_fs

#Get the free space available in the file system
FS_SIZE=$(df | grep $MOUNT_POINT | awk '{ print $4 }')
if [ ! -z "$FS_SIZE" ]; then
        # Convert to MB
        FS_SIZE=$((FS_SIZE >> 10))
        # Let us limit the script to using 1MB less than the max FS size
        FS_SIZE=$((FS_SIZE - 1))
        # If the FS is large, then the test can take a long time
        # Limit it to a resonable size
        if [ "$FS_SIZE" -gt "$TOTAL_FILE_SIZE_IN_MB" ]; then
                FS_SIZE=$TOTAL_FILE_SIZE_IN_MB
        fi
fi

loop=0
while [ $loop != $PASS_COUNT ]; do
        loop=$((loop+1))
        echo Loop: $loop        
        if [ $TEST_BONNIE == 1 ]; then
                CUR_DIR=$PWD
                cd $MOUNT_POINT
                bonnie\+\+  -u 0 -s $FS_SIZE -b
        else
                test_generic 
        fi
done
echo "Success"
cleanup

