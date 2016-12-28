#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use func qw(validity);
my $base_dir = $env::base_dir;
my $region = $env::region;
my $region_num = $env::region_num;
my @ip;


my @userID = @ARGV;
if(0 eq @userID){
	print "User ID is not specified\n";
	exit 1;
}
my $password = "";
my $obj = new validity();
foreach my $userID(@userID){
	if(!$obj->fmail($userID)){
		print "Invalid address is specified\n";
		exit 1;
	}
}

createPass(@userID);
if($region eq "JP"){
	@ip = ("ic0001-25-15", "ic0001-25-16");
	my $ret = main(@userID);
	if($ret eq 127){
		print "islanda failed\n";
	}
	@ip = ("ic0002-25-15", "ic0002-25-16");
	$ret =  main(@userID);
	if($ret eq 127){
		print "islandb failed\n";
	}
}else{
	@ip = ("ic0001-25-19","ic0001-25-22");
	my $ret = main(@userID);
	if($ret eq 127){
		print "FAILED\n";
	}
}

sub createPass(@){
	my @val = @_;
	open(OUT,">$base_dir/tmp/ssl_vpn.list");
	foreach my $pass(@val){
		print OUT "$pass,";
		$pass =~ s/@/#/;
		$pass =~ s/\./\$/g;
		$pass .= "!$env::region_num";
		print OUT "$pass\n";
	}
	close(OUT);

return 0;
}

sub main($$){
	my @ipcom;
	foreach(@ip){
		my $ip=`$base_dir/bin/cnmshow.sh $_ | grep ipaddress|awk '{print \$2}'`;
		chomp($ip);
		if("$ip" ne ""){
			push(@ipcom,$ip);
		}
	}
	my $ret;
	if(existUser(\@userID,$ipcom[0],$region_num)){
		print "User exists\n";
		exit 2;
	}
	system("expect -f $base_dir/exp/show_cluster.exp $ipcom[0] $region_num");
	my $num = activeCheck();
	system("expect -f $base_dir/exp/ssl_vpn_create.exp $ipcom[$num] $region_num > $base_dir/log/exp/ssl_vpn-$ipcom[$num].log");
	$ret = $?;
	$ret>>8;
	open(OUT, ">$base_dir/tmp/initial_mail.txt") or die "FAILED!!";
	my $initializer = `id -un`;
	chomp($initializer);
	print OUT <<EOF;
You Password has been initialized by user "$initializer".
EOF
	close(OUT);
	foreach my $user(@userID){
		system("$base_dir/pl/smtp.pl -f 'GCP_Administrator\@jp.fujitsu.com' -t '$user' -c 'c3s-global\@ml.css.fujitsu.com' -s 'Your SSL-VPN account has been created.' -d '$base_dir/tmp/initial_mail.txt'");
	}

return $ret;
}

sub activeCheck(){
	my $j = `grep "Detail:" $base_dir/log/exp/show_cluster.log|head -1`;
	chomp($j);
	if($j =~ /Active: Under running/){
		return 0;
	}else{
		return 1;
	}

return 0
}

sub existUser(){
	my $user = shift;
	my $ipcom = shift;
	my $region_num = shift;
	system("expect -f $base_dir/exp/show_user.exp $ipcom $region_num >/dev/null 2>&1");
	my $ret = $?>>8;
	if($ret eq 1){
		print "TIMEOUT $ipcom\n";
		print "Please contact 2nd line support\n";
		exit 1;
	}
	open(IN,"$base_dir/log/exp/show_user.log") or die "Cannot read a file!!";
	my $i = 0;
	while(<IN>){
		foreach my $user(@$user){
			if(/$user/){
				$i++;
			}
		}
	}
	close(IN);
	my $l = @{$user};
	if($i eq $l){
		return 1;
	}
return 0;
}
