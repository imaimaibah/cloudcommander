#!/bin/bash

. /usr/local/2nd_tools/lib/env.sh


if [ ! -e "$BASEDIR/data/region-cnm.dat" ];then
	expect -f $BASEDIR/exp/list_device_cnm.exp region-cnm > $BASEDIR/log/exp/cnmshow_region-cnm.log 2>&1
fi

for i in `$BASEDIR/pl/listIsland.pl|sed 's/\r//'|awk -F- '{print $1}'`;do
	if [ ! -e "$BASEDIR/data/$i-cnm.dat" ];then
		expect -f $BASEDIR/exp/list_device_cnm.exp $i-cnm > $BASEDIR/log/exp/cnmshow_$i-cnm.log 2>&1
	fi
done

#if [ ! -e "$BASEDIR/data/islandb-cnm.dat" ];then
#	expect -f $BASEDIR/exp/list_device_cnm.exp islandb-cnm > $BASEDIR/log/exp/cnmshow_islandb-cnm.log 2>&1
#fi
perl $BASEDIR/pl/cnmshow.pl --what-contains $1
