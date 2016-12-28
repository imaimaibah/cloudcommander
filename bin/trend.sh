#!/bin/bash

. /usr/local/2nd_tools/lib/env.sh
. $BASEDIR/lib/func.sh

HOUR=`date '+%H'`
WORKDIR="/data/trend/$TODAY/$HOUR"

if [ ! -d $WORKDIR ];then
	mkdir -p $WORKDIR
fi

$BASEDIR/exp/trend/image_trend.exp > $WORKDIR/image.log 2>/dev/null
$BASEDIR/exp/trend/lserver_trend.exp > $WORKDIR/lserver.log 2>/dev/null
$BASEDIR/exp/trend/software_trend.exp > $WORKDIR/software.log 2>/dev/null
$BASEDIR/exp/trend/software_link_trend.exp > $WORKDIR/software_link.log 2>/dev/null
$BASEDIR/exp/trend/vdisk_trend.exp > $WORKDIR/vdisk.log 2>/dev/null
$BASEDIR/exp/trend/lst_trend.exp > $WORKDIR/lst.log 2>/dev/null
$BASEDIR/exp/trend/middle_trend.exp > $WORKDIR/middle.log 2>/dev/null
$BASEDIR/exp/trend/contract.exp > $WORKDIR/contract.log 2>/dev/null
