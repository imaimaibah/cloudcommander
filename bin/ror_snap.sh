#!/bin/bash

. /usr/local/2nd_tools/lib/env.sh

func showUsage(){
	SELF=shift

	echo -e "$SELF\t[island?|region]"

return 0
}

TARGET=$1

echo $TARGET | grep -E "^(island.|region)$" > /dev/null 2>&1

if [ $? -eq 0 ];then
	if [ -e $BASEDIR/tmp/$TARGET-ror_snap ];then
		echo "$TARGET RoR snap is running"
		exit
	else
		touch $BASEDIR/tmp/$TARGET-ror_snap
	fi
	$BASEDIR/exp/ror_snap.exp $TARGET-cbrm
	rm -f $BASEDIR/tmp/$TARGET-ror_snap
else
	showUsage($0)
	exit 1
fi
exit 0
