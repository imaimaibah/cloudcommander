#!/bin/bash
#ネットワーク機器のコンフィグバックアップ

###########環境定義###########
###ディレクトリ
HOMEDIR="$HOME"
CRDIR="`cd $(dirname $0);pwd`"
BASEDIR="/usr/local/2nd_tools"
BKDIR="$BASEDIR/backup/nt_config_`date +%Y%m%d`"
BKDIR01="$BASEDIR/backup/nt_config_before_01"
BKDIR02="$BASEDIR/backup/nt_config_before_02"

###########初期処理###########
if [ "$1" = "all" ] ; then
   ls $BKDIR > /dev/null 2>&1
      if [ $? -eq 0 ] ; then
         echo "$BKDIR has already existed."
         ###ファイル削除
         rm -f $BKDIR/node_list
         rm -f $BKDIR/ip_list_sw
         rm -f $BKDIR/ip_list_rt
         rm -f $BKDIR/ip_list_asr
         rm -f $BKDIR/config_*
      else
         mkdir $BKDIR && echo "$BKDIR is created."
      fi
else
   BKDIR="$BASEDIR/backup/nt_config_`date +%Y%m%d%H%M%S`"
   mkdir $BKDIR && echo "$BKDIR is created."
fi

###ノードリスト作成
$BASEDIR/exp/node_list.exp "all" > "$BKDIR/node_list"
if [ $? -eq 0 ] ; then
  echo "$BKDIR/node_list is created."
else
  echo "$BKDIR/node_list isn't created."
    exit 1
fi

###入力チェック(引数の個数)
if [ $# -ne 1 ]; then
  echo "usage:option is wrong."
  exit 1
fi

###入力チェック(オプション)&IPアドレスリスト作成
case "$1" in
  all      )
  echo "usage:option is $1."
  cat $BKDIR/node_list |grep "rt00" |awk -F, '{print $2}'|sed 's/"//g' > $BKDIR/ip_list_rt || echo "$BKDIR/ip_list_rt isn't created."
  cat $BKDIR/node_list |grep "sw00" |awk -F, '{print $2}'|sed 's/"//g' > $BKDIR/ip_list_sw || echo "$BKDIR/ip_list_sw isn't created."
          ;;
  rt       )
  echo "usage:option is $1."
  cat $BKDIR/node_list |grep "rt00" |awk -F, '{print $2}'|sed 's/"//g' > $BKDIR/ip_list_rt || echo "$BKDIR/ip_list_rt isn't created."
          ;;
  sw       )
  echo "usage:option is $1."
  cat $BKDIR/node_list |grep "sw00" |awk -F, '{print $2}'|sed 's/"//g' > $BKDIR/ip_list_sw || echo "$BKDIR/ip_list_sw isn't created."
          ;;
  rt00*    )
  echo "usage:option is $1."
  cat $BKDIR/node_list |grep $1 |awk -F, '{print $2}'|sed 's/"//g' > $BKDIR/ip_list_rt || echo "$BKDIR/ip_list_rt isn't created."
          ;;
  sw00*   )
  echo "usage:option is $1."
  cat $BKDIR/node_list |grep $1 |awk -F, '{print $2}'|sed 's/"//g' > $BKDIR/ip_list_sw || echo "$BKDIR/ip_list_sw isn't created."
          ;;
  *   )
  echo "usage:option value is wrong."
  exit 1
esac

###IPリスト読み込み&コンフィグ(RT)の取得
test -f $BKDIR/ip_list_rt
if [ $? -eq 0 ]  ; then

  echo "Start getting rt_config."
  while read -r line; do

      [ "$line" = ""  ] && break 1

      ping "$line" -c 5 -w 10 > /dev/null 2>&1
      if [ $? -eq 0 ] ; then

          $BASEDIR/exp/bkswitches_rt.exp "$line" > $BKDIR/config_$line
          read -r $Fline < $BKDIR/config_$line

          if [ $? -eq 0 ] ; then
              echo "$line is completed."
          else
              echo "$line skip."
          fi
      else
        echo "$line skip."
      fi

  done < "$BKDIR/ip_list_rt"

fi

###IPリスト読み込み&コンフィグ(SW)の取得
test -f $BKDIR/ip_list_sw
if [ $? -eq 0 ]  ; then

  echo "Start getting sw_config."
	while read -r line; do
    
  	  [ "$line" =  ""  ] && break 1 

    	$BASEDIR/exp/bkswitches.exp "$line" 
      test -f $CRDIR/config1 > /dev/null 2>&1 && mv $CRDIR/config1 $BKDIR/config_$line > /dev/null 2>&1 

    	if [ $? -eq 0 ] ; then
         echo "$line is completed." 
    	else
        test -f $HOMEDIR/config1 > /dev/null 2>&1 && mv $HOMEDIR/config1 $BKDIR/config_$line > /dev/null 2>&1
        if [ $? -eq 0 ] ; then
           echo "$line is completed."
        else     	  
           echo "$line skip."       
        fi
    	fi

	done < "$BKDIR/ip_list_sw"

fi

###########終了処理###########
flag=0

if [ "$1" = "all" -a -d "$BKDIR01"  ] ; then
  #コンフィグリスト作成
  ls $BKDIR | grep config_ > "$BKDIR/config_list"
  ls $BKDIR01 | grep config_ > "$BKDIR01/config_list"

  #????????????????
  echo "Start comparing config files."
  test -f "$BASEDIR/backup/mail" > /dev/null 2>&1 && rm -f "$BASEDIR/backup/mail"
  flag=0

  diff "$BKDIR/config_list" "$BKDIR01/config_list" >> "$BASEDIR/backup/mail"
  if [ $? -ne 0 ] ; then
     flag=1
  fi

  #ASRのコンフィグファイルを比較対象から外す。
  cat $BKDIR/node_list |grep "rt0000-09-29" |awk -F, '{print $2}'|sed 's/"//g' >  "$BKDIR/ip_list_asr" 
  cat $BKDIR/node_list |grep "rt0000-09-32" |awk -F, '{print $2}'|sed 's/"//g' >> "$BKDIR/ip_list_asr" 
  cat $BKDIR/node_list |grep "rt0000-08-32" |awk -F, '{print $2}'|sed 's/"//g' >> "$BKDIR/ip_list_asr"
  #cat $BKDIR/node_list |grep "rt0000-02-25" |awk -F, '{print $2}'|sed 's/"//g' >> "$BKDIR/ip_list_asr"

  while read -r line; do
    [ "$line" =  ""  ] && break 1
       cat "$BKDIR/config_list" | grep -v "$line" > "$BKDIR/config_list"
  done < "$BKDIR/ip_list_asr"

  #コンフィグファイルの比較
  while read -r line; do
    [ "$line" = ""  ] && break 1 
    test -f $BKDIR01/$line
    if [ $? -eq 0 ] ; then
       diff $BKDIR/$line $BKDIR01/$line -I "ntp clock-period" > /dev/null 2>&1
       if [ $? -eq 0 ] ; then
         echo "$line is same." >> "$BASEDIR/backup/mail"
       else
         echo "$line was changed."  >> "$BASEDIR/backup/mail"
       flag=1
     fi
    else
      echo "$BKDIR01/config_list_$line dosen't exist."  >> "$BASEDIR/backup/mail"
      flag=1
    fi
  done < "$BKDIR/config_list"

  if [ "$flag" = "1" ] ; then
    $BASEDIR/pl/smtp.pl -f "gsmc-support-2nd@ml.css.fujitsu.com" -t "gsmc-support-2nd@ml.css.fujitsu.com" -s "JP01STv2 NETWORK CONFIG BACKUP FAILURE" -d "/usr/local/2nd_tools/backup/mail"
    exit 1
  fi
fi

###コンフィグファイルローテーション
if [ "$1" = "all" -a "$flag" = "0" ] ; then
    rm -fR $BKDIR02
    mv $BKDIR01 $BKDIR02 || echo "$BKDIR01 isn't moved."
    mv $BKDIR $BKDIR01   || echo "$BKDIR isn't moved."  
fi

###ファイル削除
test -f $BKDIR01/node_list > /dev/null 2>&1 && rm -f $BKDIR01/node_list
test -f $BKDIR01/ip_list_sw > /dev/null 2>&1 && rm -f $BKDIR01/ip_list_sw
test -f $BKDIR01/ip_list_rt > /dev/null 2>&1 && rm -f $BKDIR01/ip_list_rt
test -f $BKDIR01/ip_list_asr > /dev/null 2>&1 && rm -f $BKDIR01/ip_list_asr
test -f $BKDIR/config_list > /dev/null 2>&1 && rm -f $BKDIR/config_list
test -f $BKDIR01/config_list > /dev/null 2>&1 && rm -f $BKDIR01/config_list
test -f $BKDIR02/config_list > /dev/null 2>&1 && rm -f $BKDIR02/config_list

exit 0

