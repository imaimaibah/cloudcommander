#!/bin/sh


expect <<EOF > ./result.log

log_user 0
spawn ssh -l root vsys-db
expect "password" {
	send -- "sv@01011\n"
} "yes/no" {
	send -- "yes\n
	expect "password"
	send -- "sv@01011\n"
} eof {
	send_user "Can't find\n"
	exit
} timeout {
	send_user "TIMEOUT\n"
	exit
}

set timeout -1
expect "# "
send -- "/usr/local/mysql/bin/mysql -u sopuser -p sop\n"
expect -- "Enter password: "
send -- "mtm!0256\n"
expect "mysql> "
send -- "select si.vsys_id,sl.software_id from \`server#instance\` si left join software_link sl on sl.image_id = si.image_id where status not in('UNDEPLOY','UNDEPLOYING','DEPLOYING') and sl.software_id like 'ipcom%';\n"
expect -re ".*?\n"
while {1} {
	expect -re ".*\n" {
		send_user -- "\$expect_out(buffer)"
	} "mysql> " {
		break
	}
}
send -- "quit\n"
expect "# "
send -- "exit\n"
expect eof
log_user 1
EOF

#/usr/local/2nd_tools/pl/smtp.pl -t "gsmc-support-2nd@ml.css.fujitsu.co" -t "c3s-global@ml.css.fujitsu.com" -f "shin.imai@jp.fujitsu.com" -s "FW/SLB version check" -d result.log -a result.log

