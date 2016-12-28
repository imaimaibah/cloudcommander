#!/usr/bin/perl -I/usr/local/2nd_tools/lib

$|=1;

use env;
use func qw(validity);
use audit;
use POSIX ":sys_wait_h";
my $base_dir = $env::base_dir;

while(1){
	system("clear");
	print <<EOF;
1 - capacity
2 - password change for cockpit
3 - Force release VSYS
4 - Check status of VSYS
5 - Local Contents(coming soon)
6 - Notify individual customer
7 - User List
0 - Quit
EOF
	print "Choose number >> ";
	my $choice = <STDIN>;
	chomp($choice);
	if("x$choice" eq "x1"){
		capacity_page1();
	}elsif("x$choice" eq "x2"){
		password_change();
	}elsif("x$choice" eq "x3"){
		forceRelease();
	}elsif("x$choice" eq "x4"){
		checkVsys();
	}elsif("x$choice" eq "x5"){
		local_contents();
	}elsif("x$choice" eq "x6"){
		notify_user();
	}elsif("x$choice" eq "x7"){
		user_list();
	}elsif("x$choice" eq "x0"){
		exit;
	}
}

sub capacity_page1(){
	system("clear");
		show_capacity();
		print "\nHit Enter";
		<STDIN>;
return 0;
}

sub show_capacity(){
	system("clear");
	my $choice;
	if(-e "$base_dir/log/capacity-$env::today.log"){
		print "There is a capacity data for today\n";
		print "Would you like to use this data?(y/n)";
		system("stty raw -echo");
		$choice = getc();
		system("stty cooked echo");
		if($choice ne 'y' and $choice ne 'n'){
			print "\nInvalid key is entered\n";
			return;
		}
	}
	chomp($choice);
	if("x$choice" eq "xn" or "x$choice" eq "x"){
		if(my $pid = fork()){
			system("$base_dir/bin/capacity.sh > $base_dir/log/capacity-$env::today.log");
			kill(9,$pid);
			system("cat $base_dir/log/capacity-$env::today.log");
		}else{
			print "Wait";
			while (1){ 
				print ".";
				sleep 2;
			}
			exit;
		}
	}elsif("x$choice" eq "xy"){
			system("cat $base_dir/log/capacity-$env::today.log");
	}

return 0;
}

sub password_change(){
	system("clear");
	logo::logo();
	my $obj = new password();
	my $ret = $obj->Pass_change();

return $ret;
}

sub chgMon(){
	my $mon = shift;
	if($mon eq 1){
		return "Jan";
	}elsif($mon eq 2){
		return "Feb";
	}elsif($mon eq 3){
		return "Mar";
	}elsif($mon eq 4){
		return "Apr";
	}elsif($mon eq 5){
		return "May";
	}elsif($mon eq 6){
		return "Jun";
	}elsif($mon eq 7){
		return "Jul";
	}elsif($mon eq 8){
		return "Aug";
	}elsif($mon eq 9){
		return "Sep";
	}elsif($mon eq 10){
		return "Oct";
	}elsif($mon eq 11){
		return "Nov";
	}elsif($mon eq 12){
		return "Dec";
	}

return 0;
}

sub forceRelease(){
	system("clear");
	my $obj = new validity();
	my $audit = new audit();
	print "Please enter a VSYS ID which you want to release. \n";
	print ">> ";
	my $vsysID = readline(STDIN);
	chomp $vsysID;
	if($obj->vsys($vsysID)){
		$audit->audit("START releasing $vsysID");
		system("$base_dir/bin/force_release.sh $vsysID");
		my $ret = $?>>8;
		if($ret eq 0){
			$audit->audit("Release $vsysID completed");
		}else{
			$audit->audit("Release $vsysID failed");
		}
	}else{
		print "Invalid VSYS ID\n\n";
	}
	print <<EOF;
Hit Enter
EOF
	<STDIN>;

return 0;
}

sub local_contents(){

while(1){
	system("clear");
	print <<EOF;
1 - Terms of Service
2 - FAQ
3 - Cancel Agreement
4 - 404
5 - login top
0 - Go back
EOF
	print "  Choose number >> ";
	my $choice = <STDIN>;
	chomp($choice);
	if("$choice" eq "1"){
		contents("/var/opt/FJSVj2ee/deployment/ijserver/myportal/apps/myportal.war/data/en_US/application-data.xml","$base_dir/local_contents/user-pr/myportal/application-data.xml");
	}elsif("$choice" eq "2"){
		contents("/var/opt/FJSVihs/servers/FJapache/htdocs/sopdocs/pub/html/en/aboutSopFaq_en.html","$base_dir/local_contents/user-mgmt/faq/aboutSopFaq_en.html");
	}elsif("$choice" eq "3"){
		contents("/opt/FJSVihs/servers/FJapache/htdocs/sopdocs/pub/html/en/oCancel_agreement_en.html","$base_dir/local_contents/user-mgmt/cancel/oCancel_agreement_en.html");
	}elsif("$choice" eq "4"){
		contents("/opt/FJSVihs/servers/FJapache/htdocs/sopdocs/pub/404.html","$base_dir/local_contents/portal/404/404.html");
	}elsif("$choice" eq "5"){
		contents("/opt/FJSVihs/servers/FJapache/htdocs/sopdocs/pub/html/en/login_top_content_en.html","$base_dir/local_contents/user-mgmt/login_top/login_top_content_en.html");
	}elsif("$choice" eq "0"){
		last;
	}
}

return 0;
}

sub contents(){
	use sdm::local_contents;
	my $ori = shift;
	my $tmp = shift;
	my ($server) = $tmp =~ /local_contents\/([^\/]+)/;
	my $obj=new terms("$ori","$tmp");
while(1){
	system("clear");
	print <<EOF;
1 - show
2 - edit
3 - create new
4 - transfer
0 - quit
EOF
	print "  Choose number>> ";
	my $choice = <STDIN>;
	chomp($choice);
	if($choice eq '1'){
		$obj->show();
		print "\n  Choose number>> ";
		$choice = <STDIN>;
		chomp($choice);
		if($choice ne ""){
			$obj->show($choice);
		}
	}elsif($choice eq '2'){
		$obj->edit();
		$obj->transfer($server,'sv@01011','0');
	}elsif($choice eq '3'){
		$obj->paste();
		$obj->transfer($server,'sv@01011','0');
	}elsif($choice eq '4'){
		$obj->show();
		print "\n  Choose number>> ";
		$choice = <STDIN>;
		chomp($choice);
		if($choice ne ""){
			$obj->transfer($server,'sv@01011',$choice);
		}
	}elsif($choice eq '0'){
		last;
	}else{
		print "Invalid\n";
	}
	print "\nHit Enter";
	<STDIN>;
}


return 0;
}

sub checkVsys(){
	system("clear");
	print "Please enter an ID which you want to check. \n";
	print ">> ";
	my $ID = readline(STDIN);
	chomp $ID;
	my $obj = new validity();
	my $ret = $obj->typeid($ID);
	my $sql = "";
	if($ret eq 1){
		$sql = "select vsys_id,status,system_name from \`instance\` where org_id = \"$ID\";";
	}elsif($ret eq 2){
		$sql = "select server_id,status,server_name from \`server#instance\` where vsys_id = \"$ID\";";
	}elsif($ret eq 3){
		$sql = "select server_id,status,server_name from \`server#instance\` where server_id = \"$ID\";";
	}else{
		print "ID is invalid\n";
		print "\n";
		print <<EOF;
Hit Enter
EOF
		<STDIN>;
		return 1;
	}
	system("$base_dir/exp/vsys-db.exp '$sql' > $base_dir/log/exp/vsys-db.log 2>&1");
	open(IN,"$base_dir/tmp/vsys-db.list");
	while(<IN>){
		print;
	}
	close(IN);
	print "\n";
	print <<EOF;
Hit Enter
EOF
	<STDIN>;

return 0;
}

sub notify_user(){
	use func qw(validity);
	system("clear");
	print "Enter Organization ID('ALL' to notify all users.) >> ";
	my $org = readline(STDIN);
	chomp($org);
	my $obj = new validity();
	if(!$obj->org($org) and $org ne 'ALL'){
		print "Invalid organization ID\n";
		<STDIN>;
		return 1;
	}

	if($org eq 'ALL'){
		$org = '@ALL@';
	}

	print "Enter Title >> ";
	my $title = readline(STDIN);
	chomp($title);
	$title =~ s/'/\\'/g;
	$title =~ s/"/\\"/g;

	print "Enter start date in format yyyy/mm/dd >> ";
	my $start_d = readline(STDIN);
	chomp($start_d);
	my($year_s,$month_s,$day_s) = split(/\//,$start_d);
	if($year_s eq "" or $month_s eq "" or $day_s eq ""){
		print "Invalid date\n";
		<STDIN>;
		return 1;
	}
	$start_d = "$year_s-$month_s-$day_s 00:00:00";
	print "Enter end date in format yyyy/mm/dd >> ";
	my $end_d = readline(STDIN);
	chomp($end_d);
	my($year_e,$month_e,$day_e) = split(/\//,$end_d);
	if($year_e eq "" or $month_e eq "" or $day_e eq ""){
		print "Invalid date\n";
		<STDIN>;
		return 1;
	}
	$end_d = "$year_e-$month_e-$day_e 00:00:00";

	my $msg;
	open(OUT,">$base_dir/tmp/messages") or die "FAILED!!";
	print "Enter messages. Enter a single dot '.' at the end. >> \n";
	while(<STDIN>){
		chomp;
		if(/^\.$/){
			last;
		}
		$_ =~ s/'/\\'/g;
		$_ =~ s/"/\\"/g;
		print OUT;
		print OUT '\n';
	}
	close(OUT);
	system("$base_dir/exp/insert_news.exp '$org' '$title' '$start_d' '$end_d' '$base_dir/tmp/messages'");
	my $ret = $?>>8;
	if($ret eq 0){
		print "\nSUCCESS!!\n";
	}else{
		print "\nFAILED!!\n";
	}
	print "Hit Enter >>";
	<STDIN>;
	

return $ret;
}

sub user_list(){
while(1){
	system("clear");
	print <<EOF;
1 - SSL-VPN
2 - Cockpit
0 - Go back
EOF
	print "  Choose number >> ";
	my $choice = <STDIN>;
	chomp($choice);
	if("$choice" eq "1"){
		system("$base_dir/exp/ssl_vpn_user_list.exp");
	}elsif("$choice" eq "2"){
		system("$base_dir/exp/cockpit_user_list.exp");
	}elsif("$choice" eq "0"){
		last;
	}else{
		next;
	}
	print "\nHit Enter\n";
	<STDIN>;
}
return 0;
}
