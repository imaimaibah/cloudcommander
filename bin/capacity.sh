#!/bin/bash

. /usr/local/2nd_tools/lib/env.sh
REGION="TATEBAYASHI"

FROM='GCP_capacity@jp.fujitsu.com'
TO='root@mail-secure.sec.tatebayashi.sop,shin.imai@jp.fujitsu.com'
CC="y-yuichi@jp.fujitsu.com"
BCC="suzuki.hidenori@jp.fujitsu.com"
DATE_SUB=`date '+%Y/%h/%d %H:%M:%S'`
SUBJECT="$REGION GCP Capacity Data $DATE_SUB"

# Collecting Data
$BASEDIR/pl/make_data.pl > /dev/null 2>&1

# Create region CSV
$BASEDIR/pl/CSV_region.pl > /dev/null 2>&1

# Create island CSV
$BASEDIR/pl/CSV_island.pl > /dev/null 2>&1

# Out put Mail body
$BASEDIR/pl/disp_region.pl > /dev/null 2>&1

# Compress Mail attachments
cd $BASEDIR/capacity
zip $TODAY.zip ./raw/* ./region/* ./island?/* > /dev/null 2>&1

# Send the capacity data by mail
#$BASEDIR/pl/smtp.pl -f "$FROM" -t "$i" -c "$CC" -b "$BCC" -s "$SUBJECT" -d "$BASEDIR/tmp/mail" -a "$BASEDIR/tmp/$TODAY.zip"

mkdir -p "$REGION/`date '+%Y%m%d'`"
mv island? raw  region "$REGION/`date '+%Y%m%d'`"
