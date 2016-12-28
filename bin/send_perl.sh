#!/bin/bash

while [ "$1" != "" ];do
case $1 in
	-f)
		shift
		FILE=$1
		shift
		;;

	-h)
		shift
		HOST=$1
		shift
		;;

	-p)
		shift
		PASS=$1
		shift
		;;
	-u)
		shift
		USER=$1
		shift
		;;

	*)
		echo "Invalid option specified"
		echo -e "-u\t [User name]\n"
		echo -e "-p\t [Password]\n"
		echo -e "-f\t [file]\n"
		echo -e "-h\t [host name]\n"
		exit 1;
esac
done

if [ "$USER" == "" ];then
	echo "USER is not specified"
	exit 1
fi

if [ "$HOST" == "" ];then
	echo "HOST is not specified"
	exit 1
fi

if [ "$PASS" == "" ];then
	echo "PASSWROD is not specified"
	exit 1
fi

if [ "$FILE" == "" ];then
	echo "FILE is not specified"
	exit 1
fi

expect <<EOF
set timeout -1
spawn /bin/bash --norc
expect -re ".*?(\\\\$|#) "
set prompt "\$expect_out(buffer)"
send -- "cat $FILE | ssh -l $USER $HOST '/usr/bin/perl -e'\n"
expect "password" {
	send -- "$PASS\n"
} (yes/no) {
	send -- "yes\n"
	expect "password"
	send -- "$PASS\n"
}
log_user 0
expect -re ".*?\n"
send_user "\$expect_out(buffer)"
log_file -noappend log
while {1} {
	expect -re ".*\n" {
		send_log -- "\$expect_out(buffer)"
	} \$prompt {
		break
	}
}
log_file
send_user "\$expect_out(buffer)"
log_user 1
send -- "exit\n"
expect eof

EOF
