for i in `cat /tmp/VM.txt` ;do
# echo $i
 VM_name=`echo $i | cut -d , -f1`
 Host_island=`echo $i | cut -d , -f2`
 echo -n $VM_name >> /tmp/result.txt
 echo -n , >> /tmp/result.txt
 /usr/local/2nd_tools/exp/ssh_dom0_2.exp $VM_name $Host_island > /tmp/Cent.txt
# cat /tmp/Cent.txt
 result=`cat /tmp/Cent.txt | grep Kernel`

#カーネルのバージョンにより、アップデートの有無をチェックするパラメータを設定
PT1="Kernel 2.6.32-71"
PT2="Kernel 2.6.32-220"

case "$result" in
 "$PT1"*)
   cat /tmp/Cent.txt | sed -n 's/\r//gp' >  /tmp/Cent.txt
   echo -n `cat /tmp/Cent.txt | grep Cent` >> /tmp/result.txt
   echo -n  , >> /tmp/result.txt
   echo -n `cat /tmp/Cent.txt | grep Kernel` >> /tmp/result.txt
   echo -n , >> /tmp/result.txt
   echo "OLD"  >> /tmp/result.txt;;
 "$PT2"*)
   cat /tmp/Cent.txt | sed -n 's/\r//gp' >  /tmp/Cent.txt
   echo -n `cat /tmp/Cent.txt | grep Cent` >> /tmp/result.txt
   echo -n  , >> /tmp/result.txt
   echo -n `cat /tmp/Cent.txt | grep Kernel` >> /tmp/result.txt
   echo -n , >> /tmp/result.txt
   echo "NEW"  >> /tmp/result.txt;;
#VMがハングしていたりする場合の分岐を追加
  *)
   cat /tmp/Cent.txt | sed 's/\r//g' >  /tmp/Cent.txt
   echo -n `cat /tmp/Cent.txt` >> /tmp/result.txt
   echo -n , >> /tmp/result.txt
   echo -n , >> /tmp/result.txt
   echo "UNKNOWN"  >> /tmp/result.txt;;
esac
done

cat /tmp/result.txt
rm -f /tmp/result.txt
rm -f /tmp/Cent.txt

