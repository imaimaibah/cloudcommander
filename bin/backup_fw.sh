#!/bin/bash

. /usr/local/2nd_tools/lib/env.sh

if [ ! -d "$BASEDIR/backup" ];then
	mkdir "$BASEDIR/backup"
fi

CNM=`awk '$2~/islanda-cnm/ {print $1}' /etc/hosts`
FTP="10.128.240.1"

# Take a backup of DMZ-FW 
$BASEDIR/exp/dmz-fw.exp "SOPMGTCB-$MGTCB_NUM-S-0001" $FTP "nt%$REGION_NUM" > $BASEDIR/log/exp/dmz-fw.log 2>&1

# Take a backup of REGION-FW
$BASEDIR/exp/region-fw.exp $REGION_MGT "$CNM" "nt%$REGION_NUM" > $BASEDIR/log/exp/region-fw.log 2>&1

# Take a backup of ISLANDA-FW
#for i in `$BASEDIR/exp/showRegion.exp |awk -F' |-' '/island.-cbrm/ {print $2}'`;do
i="islanda"
$BASEDIR/exp/island-fw.exp $i `head -1 $BASEDIR/data/${i}_pserver/$REGION|cut -f 1`  $FTP "nt%$REGION_NUM" > $BASEDIR/log/exp/$i-fw.log 2>&1
#done
