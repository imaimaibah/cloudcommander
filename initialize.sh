#!/bin/bash

echo $1 | grep -E "prefix"

if [ $? -eq 0 ];then
	BASEDIR=`echo $1 | awk -F'=' '{print $2}'`
else
	BASEDIR="/usr/local/2nd_tools"
fi

chmod -R 755 $BASEDIR

C777="
$BASEDIR/backup
$BASEDIR/data
$BASEDIR/local_contents/user-mgmt/faq
$BASEDIR/local_contents/user-mgmt/login_top
$BASEDIR/local_contents/user-mgmt/cancel
$BASEDIR/local_contents/portal/404
$BASEDIR/local_contents/user-pr/myportal
$BASEDIR/log
$BASEDIR/log/exp
$BASEDIR/log/audit
$BASEDIR/log/ope
$BASEDIR/log/irmc
$BASEDIR/log/eternus
$BASEDIR/log/primergy
$BASEDIR/patch
$BASEDIR/tmp
"

for i in $C777;do 
	if [ ! -d $i ];then
		mkdir -p $i
	fi
	chmod 777 $i
done

if [ "$1" == "clean" ];then
	rm -f $BASEDIR/log/exp/*
	rm -f $BASEDIR/log/audit/*
	rm -f $BASEDIR/log/primergy/*
	rm -f $BASEDIR/log/eternus/*
	rm -f $BASEDIR/log/irmc/*
	rm -f $BASEDIR/log/ope/*
	rm -rf $BASEDIR/tmp/*
	rm -f $BASEDIR/backup/*
	rm -f $BASEDIR/patch/*
	rm -f $BASEDIR/data/*-cnm.dat
	rm -f $BASEDIR/local_contents/user-mgmt/faq/*
	rm -f $BASEDIR/local_contents/user-mgmt/login_top/*
	rm -f $BASEDIR/local_contents/user-mgmt/cancel/*
	rm -f $BASEDIR/local_contents/portal/404/*
	rm -f $BASEDIR/local_contents/user-pr/myportal/*
fi

touch $BASEDIR/log/audit/passwd

exit
