#!/bin/bash
#event automation

###########environment###########
HOMEDIR="$HOME"
CRDIR="`cd $(dirname $0);pwd`"
BASEDIR="/usr/local/2nd_tools"
EXECUTE=""

###########first###########
flag=0

###input check
if [ $# -ne 4 ]; then
  echo "usage:option is wrong."
  exit 1
fi

  cat $BASEDIR/tmp/event_list.txt |grep $1 |grep $2 |awk -F, '{print $1}'
  cat $BASEDIR/tmp/event_list.txt |grep $1 |grep $2 |awk -F, '{print $2}'
  cat $BASEDIR/tmp/event_list.txt |grep $1 |grep $2 |awk -F, '{print $3}'

case "$1" in
  SOP* )
  echo "filter number is $1."
  VAR=`cat $BASEDIR/tmp/event_list.txt |grep $1 |grep $2 |awk -F, '{print $3}'`
  echo "Filter number:"$1 > $BASEDIR/tmp/mail
  echo "Hostname:"$2 >> $BASEDIR/tmp/mail
  echo "Date:"$3 >> $BASEDIR/tmp/mail
  echo "Message:" >> $BASEDIR/tmp/mail
  echo $4 >> $BASEDIR/tmp/mail
  echo "" >> $BASEDIR/tmp/mail
  echo "Output:" >> $BASEDIR/tmp/mail
  $VAR $2 >> $BASEDIR/tmp/mail
  ;;
  *   )
  echo "filter number $1 was not matiched."
  exit 1
esac

###########終了処理###########
flag=0

  if [ "$flag" = "0" ] ; then
    #echo "MAIL"
    $BASEDIR/pl/smtp.pl -f "gsmc-support-2nd@ml.css.fujitsu.com" -t "awaji.takeshi@jp.fujitsu.com" -s "TEST:$2:$1" -d "/usr/local/2nd_tools/tmp/mail"
  fi

exit 0

