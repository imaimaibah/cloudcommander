#!/bin/bash

VER=1.2

function ori_dd(){
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
      test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2>  /dev/null
}

cat <<EOF
  Which region are you installing?
  1. JP01
  2. JP02
  3. AU01
  4. SG01
  5. US01
  6. UK01
  7. DE01
  8. STGV1
  9. STGV2
EOF
echo -n -e "  >>>>>>>>>> "

read REGION

echo $REGION |grep -P '^[0-9]$' > /dev/null 2>&1

if [ $? -eq 1 ];then
	echo "Invalid number is specified."
fi

if [ $REGION -eq 1 ];then
	REGION="JP01"
elif [ $REGION -eq 2 ];then
	REGION="JP02"
elif [ $REGION -eq 3 ];then
	REGION="AU01"
elif [ $REGION -eq 4 ];then
	REGION="SG01"
elif [ $REGION -eq 5 ];then
	REGION="US01"
elif [ $REGION -eq 6 ];then
	REGION="UK01"
elif [ $REGION -eq 7 ];then
	REGION="DE01"
elif [ $REGION -eq 8 ];then
	REGION="STGV1"
elif [ $REGION -eq 9 ];then
	REGION="STGV2"
else
	echo "Unknown erro occured"
	exit
fi

SKIP=`awk '/^exit \\$RETVAL$/ {print NR;exit 0;}' "$0"`

offset=`head -n +$SKIP "$0" | wc -c | tr -d " "`
filesize=`ls -l "$0" | awk '{print $5}'`
binarysize=`echo $filesize - $offset | bc`
ori_dd "$0" $offset $binarysize |tar zx -C / 2>/dev/null
RETVAL=$?

sed -i '8s/STGV2/'"$REGION"'/' /usr/local/2nd_tools/lib/env.pm
sed -i '5s/STGV2/'"$REGION"'/' /usr/local/2nd_tools/lib/env.exp
sed -i '11s/STGV2/'"$REGION"'/' /usr/local/2nd_tools/lib/env.sh

exit $RETVAL
