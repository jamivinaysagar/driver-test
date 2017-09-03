#!/bin/sh

#Description: This script is for testing display image on display device connected to DUT.
#Input Parameter: Image File Name that should be displayed on display device connected to DUT.
#Success Criteria: Image displayed successfully on display device connected to DUT.

FILE=$1
COMMAND=/usr/bin/fbdemo

usage(){
    echo "Usage: test_fbdemo.sh \$DisplayImageFileName"
    echo "Example: test_fbdemo.sh colorbar_1024x768.png"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

if [ ! -x "$COMMAND" ]; then
    echo "ERROR: fbdemo command not found!!" 
    exit 1
fi

if [ ! -e "$FILE" ]; then
    echo "ERROR: $FILE does not exist!!"
    exit 1
fi

cat /dev/fb0 > /screenshot

fbdemo $FILE &
echo "Please check the display screen of DUT to verify the image displayed successfully."
sleep 5
killall fbdemo

cat /screenshot >/dev/fb0
rm /screenshot
