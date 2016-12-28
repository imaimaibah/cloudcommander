#!/bin/bash

# Env file
. /usr/local/2nd_tools/lib/env.sh
# Include funtions
. $BASEDIR/lib/func.sh

if [ "$1" == "" ];then
	echo "option is not specified"
	exit 1
fi

# Validity check
validityVM $1
RET=$?
if [ $RET -eq 1 ];then
	echo "Invalid VSYS is specified"
	exit 1
fi

ISLAND=`$BASEDIR/pl/findIsland.pl $1`
CBRM="$ISLAND-cbrm"
$BASEDIR/exp/ssh_dom0.exp $1 $CBRM
