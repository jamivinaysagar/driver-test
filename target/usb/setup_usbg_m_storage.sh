#!/bin/sh

DIRNAME=$(dirname "$(readlink -f "$0")")

remove_module(){
set +e	
	lsmod | grep g_mass_storage > /dev/null
	if [ $? == 0 ]; then
		rmmod g_mass_storage
	fi
set -e	
}

BACKING_FILE="$DIRNAME/backing-file"

remove_module
modprobe g_mass_storage file=$BACKING_FILE
