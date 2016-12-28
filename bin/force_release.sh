#!/bin/bash

# Include 
. /usr/local/2nd_tools/lib/env.sh

# Include funtions
. $BASEDIR/lib/func.sh

if [ "$1" == "" ];then
	echo "VSYS ID is empty"
	exit 1
fi

# Validity check
validityVSYS $1
RET=$?
if [ $RET -eq 1 ];then
	echo "Invalid VSYS is specified"
	exit 1
fi

# Get VM status with in the VSYS 
$BASEDIR/exp/get_vm_status.exp $1
RET=$?
if [ $RET -eq 1 ];then
	echo "TIMEOUT"
	echo "Please contact 2nd line support"
	exit 2
fi

# Stop VMs forcibly
$BASEDIR/pl/force_stop.pl "$BASEDIR/log/exp/get_vm_status.log"
RET=$?
if [ $RET -eq 1 ];then
	echo "Aborted!!"
	exit 1
elif [ $RET -eq 2 ];then
	echo "VSYS not found"
	exit 1
elif [ $RET -eq 3 ];then
	echo "Some of the VMs failed to stop"
	echo "Please contact 2nd line support"
	exit 2
elif [ $RET -eq 4 ];then
	echo "The VSYS is already released"
	echo "Nothing to do"
	echo "Quit!!"
	exit 1
fi

echo "This will be the final warning"
echo "Please remember there is no turning back after you press 'y'"
echo "Are you really sure to delete the VMs? (y/n)"
read ANS
if [ "$ANS" != "y" ];then
	echo "Aborted!!"
	exit
else
	echo "Alright!! Let's do it"
fi

# Force release
$BASEDIR/exp/force_release.exp $1
RET=$?
if [ $RET -eq 0 ];then
	echo "SUCCESS!!"
else
	echo "FAILED!!"
	echo "Please contact 2nd line support"
	exit 2
fi

exit 0
