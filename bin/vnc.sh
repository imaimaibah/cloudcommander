#!/bin/bash

. /usr/local/2nd_tools/lib/env.sh
. $BASEDIR/lib/func.sh

VM=$1

if [ "$VM" == "" ];then
	echo "Option is needed";
	exit 1;
fi

# Validity check
validityVM $1
RET=$?
if [ $RET -eq 1 ];then
    echo "Invalid VM ID is specified"
    exit 1
fi

ISLAND=`$BASEDIR/pl/findIsland.pl $VM`
CBRM="$ISLAND-cbrm"
# $IP is ent-centos ip address
$BASEDIR/exp/vnc.exp $VM $CBRM $IP 
